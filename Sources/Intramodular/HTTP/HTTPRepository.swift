//
// Copyright (c) Vatsal Manot
//

import API
import Merge
import Swift

public protocol HTTPClient: Client where Session == HTTPSession {
    associatedtype SessionCache = HTTPCache
}

// MARK: - Implementation -

private var _HTTPClient_session_objcAssociationKey: UInt8 = 0
private var _HTTPClient_sessionCache_objcAssociationKey: UInt8 = 0
private var _HTTPClient_logger_objcAssociationKey: UInt8 = 0

extension HTTPClient  {
    public var session: HTTPSession {
        if let result = objc_getAssociatedObject(self, &_HTTPClient_session_objcAssociationKey) as? HTTPSession {
            return result
        } else {
            let result = HTTPSession()
            
            objc_setAssociatedObject(self, &_HTTPClient_session_objcAssociationKey, result, .OBJC_ASSOCIATION_RETAIN)
            
            return result
        }
    }
}

extension HTTPClient where SessionCache == HTTPCache {
    public var sessionCache: SessionCache {
        if let result = objc_getAssociatedObject(self, &_HTTPClient_sessionCache_objcAssociationKey) as? SessionCache {
            return result
        } else {
            let result = SessionCache()
            
            objc_setAssociatedObject(self, &_HTTPClient_sessionCache_objcAssociationKey, result, .OBJC_ASSOCIATION_RETAIN)
            
            return result
        }
    }
}
