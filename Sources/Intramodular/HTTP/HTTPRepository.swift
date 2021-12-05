//
// Copyright (c) Vatsal Manot
//

import API
import Merge
import Swift

public protocol HTTPRepository: Repository where Session == HTTPSession {
    associatedtype SessionCache = HTTPCache
}

// MARK: - Implementation -

private var _HTTPRepository_session_objcAssociationKey: UInt8 = 0
private var _HTTPRepository_sessionCache_objcAssociationKey: UInt8 = 0
private var _HTTPRepository_logger_objcAssociationKey: UInt8 = 0

extension HTTPRepository  {
    public var session: HTTPSession {
        if let result = objc_getAssociatedObject(self, &_HTTPRepository_session_objcAssociationKey) as? HTTPSession {
            return result
        } else {
            let result = HTTPSession()
            
            objc_setAssociatedObject(self, &_HTTPRepository_session_objcAssociationKey, result, .OBJC_ASSOCIATION_RETAIN)
            
            return result
        }
    }
}

extension HTTPRepository where SessionCache == HTTPCache {
    public var sessionCache: SessionCache {
        if let result = objc_getAssociatedObject(self, &_HTTPRepository_sessionCache_objcAssociationKey) as? SessionCache {
            return result
        } else {
            let result = SessionCache()
            
            objc_setAssociatedObject(self, &_HTTPRepository_sessionCache_objcAssociationKey, result, .OBJC_ASSOCIATION_RETAIN)
            
            return result
        }
    }
}

extension HTTPRepository  {
    public var logger: Logger? {
        get {
            objc_getAssociatedObject(self, &_HTTPRepository_session_objcAssociationKey) as? Logger
        } set {
            objc_setAssociatedObject(self, &_HTTPRepository_session_objcAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
