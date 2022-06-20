//
// Copyright (c) Vatsal Manot
//

import FoundationX
import Swallow

public struct HTTPCache: KeyedCache, Initiable {
    public typealias Key = HTTPRequest
    public typealias Value = HTTPResponse
    
    public let base = URLCache()
    
    public init() {
        
    }
    
    public func cache(_ value: Value, forKey key: Key) async throws {
        try base.storeCachedResponse(.init(value), for: .init(key))
    }
    
    public func retrieveInMemoryValue(forKey key: Key) throws -> Value? {
        
        // try base.cachedResponse(for: try URLRequest(key)).map(HTTPResponse.init)
        return nil // FIXME: The cache doesn't seem to ever expire.
    }
    
    public func removeCachedValue(forKey key: Key) async throws {
        try base.removeCachedResponse(for: .init(key))
    }
    
    public func removeAllCachedValues() async throws {
        base.removeAllCachedResponses()
    }
}
