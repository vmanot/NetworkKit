//
// Copyright (c) Vatsal Manot
//

import Foundation

extension SSE {
    public class _ServerMessageParser {
        public static let lf: UInt8 = 0x0A
        public static let semicolon: UInt8 = 0x3a
        
        public private(set) var lastMessageID: String = ""
        
        public init() {
            
        }
        
        public func parsed(
            from data: Data
        ) -> [ServerSentEvents.ServerMessage] {
            let rawMessages: [Data]
            
            if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
                rawMessages = data.split(separator: [Self.lf, Self.lf])
            } else {
                rawMessages = data.split(by: [Self.lf, Self.lf])
            }
            
            let messages: [ServerSentEvents.ServerMessage] = rawMessages.compactMap(ServerSentEvents.ServerMessage.parse(from:))
            
            if let lastMessageWithId = messages.last(where: { $0.id != nil }) {
                lastMessageID = lastMessageWithId.id ?? ""
            }
            
            return messages
        }
        
        public func reset() {
            lastMessageID = ""
        }
    }
}

extension SSE.ServerMessage {
    public static func parse(
        from data: Data
    ) -> Self? {
        let rows = data.split(separator: SSE._ServerMessageParser.lf)
        
        var message = SSE.ServerMessage()
        
        for row in rows {
            let keyValue = row.split(separator: SSE._ServerMessageParser.semicolon, maxSplits: 1)
            let key = keyValue[0].utf8String
            let value = keyValue[1].utf8String
            
            switch key {
                case "id":
                    message.id = value.trimmingCharacters(in: .whitespacesAndNewlines)
                case "event":
                    message.event = value.trimmingCharacters(in: .whitespacesAndNewlines)
                case "data":
                    if let existingData = message.data {
                        message.data = existingData + "\n" + value.trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        message.data = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                case "time":
                    message.time = value.trimmingCharacters(in: .whitespacesAndNewlines)
                default:
                    continue
            }
        }
        
        if message.isEmpty {
            return nil
        }
        
        return message
    }
}

extension Data {
    fileprivate func split(
        by separator: [UInt8]
    ) -> [Data] {
        let doubleNewline = Data(separator)
        var splits: [Data] = []
        var currentIndex = 0
        var range: Range<Data.Index>?
        
        while true {
            range = self.range(of: doubleNewline, options: [], in: currentIndex..<self.count)
            if let foundRange = range {
                splits.append(self.subdata(in: currentIndex..<foundRange.lowerBound))
                currentIndex = foundRange.upperBound
            } else {
                splits.append(self.subdata(in: currentIndex..<self.count))
                break
            }
        }
        
        return splits
    }
}

fileprivate extension Data {
    var utf8String: String {
        String(decoding: self, as: UTF8.self)
    }
}
