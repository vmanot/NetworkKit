//
// Copyright (c) Vatsal Manot
//

import API
import Merge
import Swift

public protocol HTTPRepository: Repository where Session == HTTPSession {
    associatedtype Session = HTTPSession
}

open class HTTPRepositoryBase<Interface: HTTPInterface>: RepositoryBase<Interface, HTTPSession>, HTTPRepository {
    
}

// MARK: - Implementation -

private var session_objcAssociationKey: Void = ()

extension HTTPRepository  {
    public var session: HTTPSession {
        if let result = objc_getAssociatedObject(self, &session_objcAssociationKey) as? HTTPSession {
            return result
        } else {
            let result = HTTPSession()
            
            objc_setAssociatedObject(self, &session_objcAssociationKey, result, .OBJC_ASSOCIATION_RETAIN)
            
            return result
        }
    }
}
