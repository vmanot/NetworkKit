//
// Copyright (c) Vatsal Manot
//

import Foundation

extension ServerSentEvents {
    public struct ServerMessage: Hashable, Sendable {
        public var id: String?
        public var event: String?
        public var data: String?
        public var time: String?
        
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
