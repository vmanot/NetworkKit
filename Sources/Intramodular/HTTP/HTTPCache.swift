//
// Copyright (c) Vatsal Manot
//

import FoundationX
import Swallow

public struct HTTPCache: CacheProtocol, Initiable {
    public typealias Key = HTTPRequest
    public typealias Value = HTTPResponse
    
    public let base = URLCache()
    
    public init() {
        
    }
    
    public func cache(_ value: Value, forKey key: Key) -> AnySingleOutputPublisher<Void, Error> {
        Result {
            try base.storeCachedResponse(.init(value), for: .init(key))
        }
        .publisher
        .eraseToAnySingleOutputPublisher()
    }
    
    public func decacheInMemoryValue(forKey key: Key) throws -> Value? {
        // try base.cachedResponse(for: try URLRequest(key)).map(HTTPResponse.init)
        return nil // FIXME: The cache doesn't seem to ever expire.
    }
    
    public func removeCachedValue(forKey key: Key) -> AnySingleOutputPublisher<Void, Error> {
        Result {
            try base.removeCachedResponse(for: .init(key))
        }
        .publisher
        .eraseToAnySingleOutputPublisher()
    }
    
    public func removeAllCachedValues() -> AnySingleOutputPublisher<Void, Error> {
        Result {
            base.removeAllCachedResponses()
        }
        .publisher
        .eraseToAnySingleOutputPublisher()
    }
}
