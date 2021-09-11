//
// Copyright (c) Vatsal Manot
//

import API
import Merge
import Swift

public protocol HTTPRepository: Repository where Session == HTTPSession {
    associatedtype Cache = HTTPCache
}

// MARK: - Implementation -

private var _HTTPRepository_cache_objcAssociationKey: UInt8 = 0
private var _HTTPRepository_logger_objcAssociationKey: UInt8 = 0
private var _HTTPRepository_session_objcAssociationKey: UInt8 = 0

extension HTTPRepository where Cache == HTTPCache {
    public var cache: Cache {
        if let result = objc_getAssociatedObject(self, &_HTTPRepository_cache_objcAssociationKey) as? Cache {
            return result
        } else {
            let result = Cache()
            
            objc_setAssociatedObject(self, &_HTTPRepository_cache_objcAssociationKey, result, .OBJC_ASSOCIATION_RETAIN)
            
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
