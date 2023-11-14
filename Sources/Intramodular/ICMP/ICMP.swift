//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Foundation
import Darwin
import Swift

public enum ICMPType: UInt8 {
    case echoReply = 0
    case echoRequest = 8
}

/// The structure of an ICMP header.
struct ICMPHeader {
    /// Type of message
    var type: UInt8
    /// Type sub code
    var code: UInt8
    /// One's complement checksum of struct
    var checksum: UInt16
    /// Identifier
    var identifier: UInt16
    /// Sequence number
    var sequenceNumber: UInt16
    /// UUID payload
    var payload: uuid_t
    
    public static func package(
        identifier: UInt16,
        sequenceNumber: UInt16,
        fingerprint: UUID
    ) throws -> Self {
        var result = ICMPHeader(
            type: ICMPType.echoRequest.rawValue,
            code: 0,
            checksum: 0,
            identifier: CFSwapInt16HostToBig(identifier),
            sequenceNumber: CFSwapInt16HostToBig(sequenceNumber),
            payload: fingerprint.uuid
        )
        
        try result.computeChecksum()
        
        return result
    }
}

extension ICMPHeader {
    @discardableResult
    mutating func computeChecksum() throws -> UInt16 {
        func convert(payload: uuid_t) -> [UInt8] {
            let p = payload
            
            let _p: [UInt8] = [
                p.0,
                p.1,
                p.2,
                p.3,
                p.4,
                p.5,
                p.6,
                p.7,
                p.8,
                p.9,
                p.10,
                p.11,
                p.12,
                p.13,
                p.14,
                p.15
            ]
                
            return _p.map({ UInt8($0) })
        }
        
        let typecode = Data([type, code]).withUnsafeBytes {
            $0.load(as: UInt16.self)
        }
        var sum = UInt64(typecode) 
        
        sum += UInt64(identifier)
        sum += UInt64(sequenceNumber)
        
        let payload = convert(payload: self.payload)
        
        guard payload.count % 2 == 0 else {
            throw Ping.Error.unexpectedPayloadLength
        }
        
        var i = 0
        while i < payload.count {
            guard payload.indices.contains(i + 1) else {
                throw Ping.Error.unexpectedPayloadLength
            }
            // Convert two 8 byte ints to one 16 byte int
            sum += Data([payload[i], payload[i + 1]]).withUnsafeBytes {
                UInt64($0.load(as: UInt16.self))
            }
            i += 2
        }
        while sum >> 16 != 0 {
            sum = (sum & 0xffff) + (sum >> 16)
        }
        
        guard sum < UInt16.max else { throw Ping.Error.checksumOutOfBounds }
        
        let oldChecksum = self.checksum
        
        checksum = ~UInt16(sum)
        
        return oldChecksum
    }
}

#endif
