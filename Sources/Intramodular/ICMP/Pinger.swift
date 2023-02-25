//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Combine
import Foundation
import Darwin
import Merge

#if os(iOS)
import UIKit
#endif

public final class Pinger: _MutexProtectedType, @unchecked Sendable {
    public let mutex = DispatchMutexDevice()
    
    public let output = PassthroughSubject<Ping.Response, Never>()
    
    /// The destination to ping.
    public let destination: Ping.Destination
    /// The configuration of the pinger.
    public let configuration: Ping.Configuration
    
    /// The number of pings to make. Default is `nil`, which means no limit.
    public var targetCount: Int? = nil
    
    @MutexProtected
    private var killswitch = false
    @MutexProtected
    private var sequenceIndex = 0
    @MutexProtected
    private var isPinging = false
    @MutexProtected
    private var timeoutTimer: Timer? = nil
    @MutexProtected
    private var wasHaltedByApplicationStageChange = false
    
    /// A random identifier which is a part of the ping request.
    private let identifier = UInt16.random(in: 0..<UInt16.max)
    /// A random UUID fingerprint sent as the payload.
    private let fingerprint = UUID()
    /// User-specified dispatch queue. The `observer` is always called from this queue.
    private let queue: DispatchQueue
    /// Socket for sending and receiving data.
    private var socket: CFSocket?
    /// Socket source
    private var socketSource: CFRunLoopSource?
    /// When the current request was sent.
    private var sequenceStart: Date?
    
    /// The current ping count, starting from 0.
    public var currentCount: Int {
        return sequenceIndex
    }
    
    /// Initializes a pinger.
    ///
    /// - Parameter destination: Specifies the host.
    /// - Parameter configuration: A configuration object which can be used to customize pinging behavior.
    /// - Parameter queue: All responses are delivered through this dispatch queue.
    public init(
        destination: Ping.Destination,
        configuration: Ping.Configuration,
        qos: DispatchQoS.QoSClass
    ) throws {
        self.destination = destination
        self.configuration = configuration
        self.queue = .global(qos: qos)
        
        try createSocket()
        
        #if os(iOS)
        if configuration.handleBackgroundTransitions {
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        #endif
    }
    
    // MARK: - Tear-down
    deinit {
        if socketSource != nil {
            CFRunLoopSourceInvalidate(socketSource)
            socketSource = nil
        }
        socket = nil
        timeoutTimer?.invalidate()
        $timeoutTimer.assignedValue = nil
    }
}

extension Pinger {
    public func start() throws {
        if socket == nil {
            try createSocket()
        }
        
        $killswitch.assignedValue = false
        
        ping()
    }
    
    public func stop(resetSequence: Bool = true) {
        $killswitch.assignedValue = true
        $isPinging.assignedValue = false
        
        self.resetSequence()
    }
    
    public func halt(resetSequence: Bool = true) {
        stop(resetSequence: resetSequence)
        
        if socketSource != nil {
            CFRunLoopSourceInvalidate(socketSource)
        }
        socketSource = nil
        socket = nil
    }
}

extension Pinger {
    @objc private func applicationDidEnterBackground() {
        $wasHaltedByApplicationStageChange.assignedValue = true
        
        halt(resetSequence: false)
    }
    
    @objc private func applicationDidEnterForeground() {
        if wasHaltedByApplicationStageChange {
            $wasHaltedByApplicationStageChange.assignedValue = false
            
            try? start()
        }
    }
}

extension Pinger {
    private func ping() {
        if isPinging || killswitch {
            return
        }
        $isPinging.mutate({ $0 = true })
        sequenceStart = Date()
        
        self.$timeoutTimer.mutate {
            $0 = Timer(
                timeInterval: self.configuration.timeoutInterval,
                target: self,
                selector: #selector(self.timeout),
                userInfo: nil,
                repeats: false
            )
            
            RunLoop.main.add($0!, forMode: .common)
        }
        
        queue.async {
            let address = self.destination.ipv4Address
            
            do {
                let icmpPackage = withUnsafeBytes(of: try ICMPHeader.package(identifier: self.identifier, sequenceNumber: UInt16(self.sequenceIndex), fingerprint: self.fingerprint)) { header in
                    Data(bytes: header.baseAddress!, count: MemoryLayout<ICMPHeader>.size)
                }
                
                guard let socket = self.socket else { return }
                let socketError = CFSocketSendData(socket, address as CFData, icmpPackage as CFData, self.configuration.timeoutInterval)
                
                if socketError != .success {
                    var error: Ping.Error?
                    
                    switch socketError {
                        case .error: error = .requestError
                        case .timeout: error = .requestTimeout
                        default: break
                    }
                    let response = Ping.Response(
                        identifier: self.identifier,
                        ipAddress: self.destination.ip,
                        sequenceNumber: self.sequenceIndex,
                        duration: self.timeIntervalSinceStart,
                        error: error,
                        byteCount: nil,
                        ipHeader: nil
                    )
                    
                    self.$isPinging.mutate({ $0 = false })
                    self.informObserver(of: response)
                    
                    return self.scheduleNextPing()
                }
            } catch {
                let response = Ping.Response(
                    identifier: self.identifier,
                    ipAddress: self.destination.ip,
                    sequenceNumber: self.sequenceIndex,
                    duration: self.timeIntervalSinceStart,
                    error: error as? Ping.Error ?? .packageCreationFailed,
                    byteCount: nil,
                    ipHeader: nil
                )
                
                self.$isPinging.assignedValue = false
                self.informObserver(of: response)
                self.scheduleNextPing()
            }
        }
    }
    
    private var timeIntervalSinceStart: TimeInterval? {
        if let start = sequenceStart {
            return Date().timeIntervalSince(start)
        }
        return nil
    }
    
    @objc private func timeout() {
        let error = Ping.Error.responseTimeout
        let response = Ping.Response(
            identifier: self.identifier,
            ipAddress: self.destination.ip,
            sequenceNumber: self.sequenceIndex,
            duration: timeIntervalSinceStart,
            error: error,
            byteCount: nil,
            ipHeader: nil
        )
        
        $isPinging.mutate({ $0 = false })
        
        informObserver(of: response)
        
        incrementSequenceIndex()
        scheduleNextPing()
    }
    
    private func informObserver(of response: Ping.Response) {
        if killswitch { return }
        queue.sync {
            output.send(response)
        }
    }
    
    private var shouldSchedulePing: Bool {
        guard !killswitch else {
            return false
        }
        
        if let target = targetCount {
            if sequenceIndex < target {
                return true
            }
            return false
        }
        return true
    }
    
    private func scheduleNextPing() {
        if shouldSchedulePing {
            queue.asyncAfter(deadline: .now() + configuration.pingInterval) {
                self.ping()
            }
        }
    }
    
    private func resetSequence() {
        $sequenceIndex.assignedValue = 0
        sequenceStart = nil
    }
    
    private func incrementSequenceIndex() {
        if sequenceIndex >= Int.max {
            $sequenceIndex.mutate({ $0 = 1 })
        } else {
            $sequenceIndex.mutate {
                $0 += 1
            }
        }
    }
}

extension Pinger {
    private func createSocket() throws {
        class SocketInfo {
            let pinger: Pinger
            let identifier: UInt16
            
            init(pinger: Pinger, identifier: UInt16) {
                self.pinger = pinger
                self.identifier = identifier
            }
        }
        
        // Create a socket context...
        let info = SocketInfo(pinger: self, identifier: identifier)
        var context = CFSocketContext(version: 0, info: Unmanaged.passRetained(info).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        
        // ...and a socket...
        socket = CFSocketCreate(kCFAllocatorDefault, AF_INET, SOCK_DGRAM, IPPROTO_ICMP, CFSocketCallBackType.dataCallBack.rawValue, { socket, type, address, data, info in
            // Socket callback closure
            guard let socket = socket, let info = info, let data = data else { return }
            let socketInfo = Unmanaged<SocketInfo>.fromOpaque(info).takeUnretainedValue()
            let ping = socketInfo.pinger
            if (type as CFSocketCallBackType) == CFSocketCallBackType.dataCallBack {
                let cfdata = Unmanaged<CFData>.fromOpaque(data).takeUnretainedValue()
                ping.socket(socket: socket, didReadData: cfdata as Data)
            }
            
        }, &context)
        
        // Disable SIGPIPE, see issue #15 on GitHub.
        let handle = CFSocketGetNative(socket)
        var value: Int32 = 1
        let err = setsockopt(handle, SOL_SOCKET, SO_NOSIGPIPE, &value, socklen_t(MemoryLayout.size(ofValue: value)))
        guard err == 0 else {
            throw Ping.Error.socketOptionsSetError(err: err)
        }
        
        // ...and add it to the main run loop.
        socketSource = CFSocketCreateRunLoopSource(nil, socket, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), socketSource, .commonModes)
    }
    
    private func socket(socket: CFSocket, didReadData data: Data?) {
        guard !killswitch else {
            return
        }
        
        guard let data = data else {
            return
        }
        
        var validationError: Ping.Error? = nil
        
        do {
            let validation = try validateResponse(from: data)
            if !validation { return }
        } catch let error as Ping.Error {
            validationError = error
        } catch {
            print("Unhandled error thrown: \(error)")
        }
        
        timeoutTimer?.invalidate()
        
        var ipHeader: IPv4Header? = nil
        
        if validationError == nil {
            ipHeader = data.withUnsafeBytes({ $0.load(as: IPv4Header.self) })
        }
        
        let response = Ping.Response(
            identifier: identifier,
            ipAddress: destination.ip,
            sequenceNumber: sequenceIndex,
            duration: timeIntervalSinceStart,
            error: validationError,
            byteCount: data.count,
            ipHeader: ipHeader
        )
        
        $isPinging.assignedValue = false
        
        informObserver(of: response)
        incrementSequenceIndex()
        scheduleNextPing()
    }
}

extension Pinger {
    /// Initializes a pinger from an IPv4 address string.
    ///
    /// - Parameter ipv4Address: The host's IP address.
    /// - Parameter configuration: A configuration object which can be used to customize pinging behavior.
    /// - Parameter queue: All responses are delivered through this dispatch queue.
    public convenience init(
        ipv4Address: String,
        config configuration: Ping.Configuration,
        qos: DispatchQoS.QoSClass
    ) throws {
        var socketAddress = sockaddr_in()
        
        socketAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        socketAddress.sin_family = UInt8(AF_INET)
        socketAddress.sin_port = 0
        socketAddress.sin_addr.s_addr = inet_addr(ipv4Address.cString(using: .utf8))
        let data = Data(bytes: &socketAddress, count: MemoryLayout<sockaddr_in>.size)
        
        let destination = Ping.Destination(host: ipv4Address, ipv4Address: data)
        try self.init(destination: destination, configuration: configuration, qos: qos)
    }
    /// Initializes a pinger from a given host string.
    ///
    /// - Parameter host: A string describing the host. This can be an IP address or host name.
    /// - Parameter configuration: A configuration object which can be used to customize pinging behavior.
    /// - Parameter queue: All responses are delivered through this dispatch queue.
    /// - Throws: A `Ping.Error` if the given host could not be resolved.
    public convenience init(
        host: String,
        configuration: Ping.Configuration,
        qos: DispatchQoS.QoSClass
    ) throws {
        let result = try Ping.Destination.getIPv4AddressFromHost(host: host)
        let destination = Ping.Destination(host: host, ipv4Address: result)
        
        try self.init(destination: destination, configuration: configuration, qos: qos)
    }
}

extension Pinger {
    private func validateResponse(from data: Data) throws -> Bool {
        func icmpHeaderOffset(of packet: Data) -> Int? {
            if packet.count >= MemoryLayout<IPv4Header>.size + MemoryLayout<ICMPHeader>.size {
                let ipHeader = packet.withUnsafeBytes({ $0.load(as: IPv4Header.self) })
                if ipHeader.versionAndHeaderLength & 0xF0 == 0x40 && ipHeader.protocol == IPPROTO_ICMP {
                    let headerLength = Int(ipHeader.versionAndHeaderLength) & 0x0F * MemoryLayout<UInt32>.size
                    if packet.count >= headerLength + MemoryLayout<ICMPHeader>.size {
                        return headerLength
                    }
                }
            }
            return nil
        }
        
        guard data.count >= MemoryLayout<ICMPHeader>.size + MemoryLayout<IPv4Header>.size else {
            throw Ping.Error.invalidLength(received: data.count)
        }
        
        guard let headerOffset = icmpHeaderOffset(of: data) else { throw Ping.Error.invalidHeaderOffset }
        var icmpHeader = data.withUnsafeBytes({ $0.load(fromByteOffset: headerOffset, as: ICMPHeader.self) })
        
        let uuid = UUID(uuid: icmpHeader.payload)
        guard uuid == fingerprint else {
            // Wrong handler, ignore this response
            return false
        }
        
        let oldChecksum = try icmpHeader.computeChecksum()
        
        guard icmpHeader.checksum == oldChecksum else {
            throw Ping.Error.checksumMismatch(received: oldChecksum, calculated: icmpHeader.checksum)
        }
        
        guard icmpHeader.type == ICMPType.echoReply.rawValue else {
            throw Ping.Error.invalidType(received: icmpHeader.type)
        }
        
        guard icmpHeader.code == 0 else {
            throw Ping.Error.invalidCode(received: icmpHeader.code)
        }
        
        guard CFSwapInt16BigToHost(icmpHeader.identifier) == identifier else {
            throw Ping.Error.identifierMismatch(received: icmpHeader.identifier, expected: identifier)
        }
        
        let receivedSequenceIndex = CFSwapInt16BigToHost(icmpHeader.sequenceNumber)
        
        guard receivedSequenceIndex == sequenceIndex else {
            throw Ping.Error.invalidSequenceIndex(received: Int(receivedSequenceIndex), expected: sequenceIndex)
        }
        
        return true
    }
}

#endif
