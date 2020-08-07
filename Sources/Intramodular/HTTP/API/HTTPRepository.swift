//
// Copyright (c) Vatsal Manot
//

import API
import Merge
import Swift

public protocol HTTPRepository: Repository where Session == HTTPSession {
    
}

open class HTTPRepositoryBase<Interface: HTTPInterface>: RepositoryBase<Interface, HTTPSession>, HTTPRepository {
    
}
