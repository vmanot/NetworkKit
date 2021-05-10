//
// Copyright (c) Vatsal Manot
//

import Foundation
import Network
import os

/// TLVMessageProtocol implements a simple Type-Length-Message protocol
public final class TLVMessageProtocol: NWProtocolFramerImplementation {
    public static var label: String {
        String(describing: TLVMessageProtocol.self)
    }
    
    public static var definition: NWProtocolFramer.Definition {
        NWProtocolFramer.Definition(implementation: TLVMessageProtocol.self)
    }
    
    public required init(framer: NWProtocolFramer.Instance) {
        
    }
    
    public func start(framer: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult {
        return .ready
    }
    
    public func handleInput(framer: NWProtocolFramer.Instance) -> Int {
        while true {
            // Try to read out a single header.
            var tempHeader: Header?
            let headerSize = Header.encodedSize
            let parsed = framer.parseInput(
                minimumIncompleteLength: headerSize,
                maximumLength: headerSize
            ) { (buffer, _) -> Int in
                guard let buffer = buffer else {
                    return 0
                }
                
                if buffer.count < headerSize {
                    return 0
                }
                
                tempHeader = Header(buffer)
                return headerSize
            }
            
            // If you can't parse out a complete header, stop parsing and ask for headerSize more bytes.
            guard parsed, let header = tempHeader else {
                return headerSize
            }
            
            let message = NWProtocolFramer.Message(messageType: header.type)
            
            // Deliver the body of the message, along with the message object.
            if !framer.deliverInputNoCopy(length: Int(header.length), message: message, isComplete: true) {
                return 0
            }
        }
    }
    
    public func handleOutput(
        framer: NWProtocolFramer.Instance,
        message: NWProtocolFramer.Message,
        messageLength: Int,
        isComplete: Bool
    ) {
        let header = Header(type: message.messageType, length: UInt32(messageLength))
        
        framer.writeOutput(data: header.encodedData)
        
        do {
            try framer.writeOutputNoCopy(length: messageLength)
        } catch let error {
            os_log("Hit error writing: %@", error.localizedDescription)
        }
    }
    
    public func wakeup(framer: NWProtocolFramer.Instance) {
        
    }
    
    public func stop(framer: NWProtocolFramer.Instance) -> Bool {
        return true
    }
    
    public func cleanup(framer: NWProtocolFramer.Instance) {
        
    }
}

extension TLVMessageProtocol {
    public struct Header: Codable, Hashable {
        static var encodedSize: Int {
            return MemoryLayout<UInt32>.size * 2
        }
        
        let type: UInt32
        let length: UInt32
        
        var encodedData: Data {
            var tempType = type
            var tempLength = length
            var data = Data(bytes: &tempType, count: MemoryLayout<UInt32>.size)
            
            data.append(Data(bytes: &tempLength, count: MemoryLayout<UInt32>.size))
            
            return data
        }
        
        init(type: UInt32, length: UInt32) {
            self.type = type
            self.length = length
        }
        
        init(_ buffer: UnsafeMutableRawBufferPointer) {
            var tempType: UInt32 = 0
            var tempLength: UInt32 = 0
            withUnsafeMutableBytes(of: &tempType) { typePtr in
                typePtr.copyMemory(from: UnsafeRawBufferPointer(start: buffer.baseAddress!.advanced(by: 0),
                                                                count: MemoryLayout<UInt32>.size))
            }
            withUnsafeMutableBytes(of: &tempLength) { lengthPtr in
                lengthPtr.copyMemory(from: UnsafeRawBufferPointer(start: buffer.baseAddress!.advanced(by: MemoryLayout<UInt32>.size),
                                                                  count: MemoryLayout<UInt32>.size))
            }
            type = tempType
            length = tempLength
        }
    }
}

extension NWProtocolFramer.Message {
    convenience init(messageType: UInt32) {
        self.init(definition: TLVMessageProtocol.definition)
        
        self.messageType = messageType
    }
    
    var messageType: UInt32 {
        get {
            if let messageType = self["MessageType"] as? UInt32 {
                return messageType
            } else {
                return 0
            }
        } set {
            self["MessageType"] = newValue
        }
    }
}
