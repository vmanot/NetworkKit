//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Combine
import Foundation
import Darwin

public struct Ping {
    
}

extension Ping {
    public struct Destination: Sendable {
        /// The host name, can be a IP address or a URL.
        let host: String
        /// IPv4 address of the host.
        let ipv4Address: Data
        /// Socket address of `ipv4Address`.
        var socketAddress: sockaddr_in? {
            ipv4Address.withUnsafeBytes({ $0.load(as: sockaddr_in.self) })
        }
    }
}

extension Ping {
    /// Controls pinging behaviour.
    public struct Configuration: Sendable {
        /// The time between consecutive pings in seconds.
        let pingInterval: TimeInterval
        /// Timeout interval in seconds.
        let timeoutInterval: TimeInterval
        /// If `true`, then `SwiftyPing` will automatically halt and restart the pinging when the app state changes. Only applicable on iOS. If `false`, then the user is responsible for appropriately handling app state changes, see issue #15 on GitHub.
        var handleBackgroundTransitions = true
        
        /// Initializes a `Ping.Configuration` object with the given parameters.
        /// - Parameter interval: The time between consecutive pings in seconds. Defaults to 1.
        /// - Parameter timeout: Timeout interval in seconds. Defaults to 5.
        public init(interval: TimeInterval = 1, with timeout: TimeInterval = 5) {
            pingInterval = interval
            timeoutInterval = timeout
        }
        /// Initializes a `Ping.Configuration` object with the given interval.
        /// - Parameter interval: The time between consecutive pings in seconds.
        /// - Note: Timeout interval will be set to 5 seconds.
        public init(interval: TimeInterval) {
            self.init(interval: interval, with: 5)
        }
    }
}

extension Ping {
    /// A struct encapsulating a ping response.
    public struct Response {
        /// The randomly generated identifier used in the ping header.
        public let identifier: UInt16
        /// The IP address of the host.
        public let ipAddress: String?
        /// Running sequence number, starting from 0.
        public let sequenceNumber: Int
        /// Roundtrip time.
        public let duration: TimeInterval?
        /// An error associated with the response.
        public let error: Ping.Error?
        /// Response data packet size in bytes.
        public let byteCount: Int?
        /// Response IP header.
        public let ipHeader: IPv4Header?
    }
}

extension Ping {
    public enum Error: Swift.Error, Equatable {
        // MARK: Response
        
        /// The response took longer to arrive than `configuration.timeoutInterval`.
        case responseTimeout
        
        // MARK: Response Validation
        
        /// The response length was too short.
        case invalidLength(received: Int)
        /// The received checksum doesn't match the calculated one.
        case checksumMismatch(received: UInt16, calculated: UInt16)
        /// Response `type` was invalid.
        case invalidType(received: ICMPType.RawValue)
        /// Response `code` was invalid.
        case invalidCode(received: UInt8)
        /// Response `identifier` doesn't match what was sent.
        case identifierMismatch(received: UInt16, expected: UInt16)
        /// Response `sequenceNumber` doesn't match.
        case invalidSequenceIndex(received: Int, expected: Int)
        
        // MARK: Host Resolution
        
        /// Unknown error occured within host lookup.
        case unknownHostError
        /// Address lookup failed.
        case addressLookupError
        /// Host was not found.
        case hostNotFound
        /// Address data could not be converted to `sockaddr`.
        case addressMemoryError
        
        // MARK: Request
        
        /// An error occured while sending the request.
        case requestError
        /// The request send timed out. Note that this is not "the" timeout,
        /// that would be `responseTimeout`. This timeout means that
        /// the ping request wasn't even sent within the timeout interval.
        case requestTimeout
        
        // MARK: Internal
        
        /// Checksum is out-of-bounds for `UInt16` in `computeCheckSum`. This shouldn't occur, but if it does, this error ensures that the app won't crash.
        case checksumOutOfBounds
        /// Unexpected payload length.
        case unexpectedPayloadLength
        /// Unspecified package creation error.
        case packageCreationFailed
        /// For some reason, the socket is `nil`. This shouldn't ever happen, but just in case...
        case socketNil
        /// The ICMP header offset couldn't be calculated.
        case invalidHeaderOffset
        /// Failed to change socket options, in particular SIGPIPE.
        case socketOptionsSetError(err: Int32)
    }
}

extension Ping.Destination {
    /// IP address of the host.
    var ip: String? {
        guard let address = socketAddress else { return nil }
        return String(cString: inet_ntoa(address.sin_addr), encoding: .ascii)
    }
    
    /// Resolves the `host`.
    static func getIPv4AddressFromHost(host: String) throws -> Data {
        var streamError = CFStreamError()
        let cfhost = CFHostCreateWithName(nil, host as CFString).takeRetainedValue()
        let status = CFHostStartInfoResolution(cfhost, .addresses, &streamError)
        
        var data: Data?
        
        if !status {
            if Int32(streamError.domain) == kCFStreamErrorDomainNetDB {
                throw Ping.Error.addressLookupError
            } else {
                throw Ping.Error.unknownHostError
            }
        } else {
            var success: DarwinBoolean = false
            guard let addresses = CFHostGetAddressing(cfhost, &success)?.takeUnretainedValue() as? [Data] else {
                throw Ping.Error.hostNotFound
            }
            
            for address in addresses {
                let addrin = address.withUnsafeBytes({ $0.load(as: sockaddr.self) })
                if address.count >= MemoryLayout<sockaddr>.size && addrin.sa_family == UInt8(AF_INET) {
                    data = address
                    break
                }
            }
            
            if data?.count == 0 || data == nil {
                throw Ping.Error.hostNotFound
            }
        }
        guard let returnData = data else {
            throw Ping.Error.unknownHostError
        }
        
        return returnData
    }
}

#endif
