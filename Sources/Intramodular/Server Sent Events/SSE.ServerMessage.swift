//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation

extension ServerSentEvents {
    public struct ServerMessage: Hashable, Sendable {
        public package(set) var id: String?
        public package(set) var event: String?
        public package(set) var data: String?
        public package(set) var time: String?
        
        init(
            id: String? = nil,
            event: String? = nil,
            data: String? = nil,
            time: String? = nil
        ) {
            self.id = id
            self.event = event
            self.data = data
            self.time = time
        }
        
        public func decode<T: Decodable>(_ type: T.Type) throws -> T {
            guard let data: String else {
                throw Never.Reason.illegal
            }
            
            let result: Any
            
            switch type {
                case JSON.self:
                    result = try JSON(jsonString: data)
                default:
                    return try JSON(jsonString: data).decode(type, keyDecodingStrategy: .convertFromSnakeCase)
            }
            
            return try cast(result)
        }
    }
}

extension SSE.ServerMessage {
    public var isEmpty: Bool {
        if let id, !id.isEmpty {
            return false
        }
        
        if let event, !event.isEmpty {
            return false
        }
        
        if let data, !data.isEmpty {
            return false
        }
        
        if let time, !time.isEmpty {
            return false
        }
        
        return true
    }
}
