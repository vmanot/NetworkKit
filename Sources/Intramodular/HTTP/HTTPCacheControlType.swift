//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPCacheControlType: Hashable, Sendable {
    case noCache
    case noStore
    case noTransform
    case onlyIfCached
    case maxAge(seconds: Int)
    case maxStale(seconds: Int?)
    case minFresh(seconds: Int)
    
    public var value: String {
        switch self {
            case .noCache:
                return "no-cache"
            case .noStore:
                return "no-store"
            case .noTransform:
                return "no-transform"
            case .onlyIfCached:
                return "only-if-cached"
            case .maxAge(let seconds):
                return "max-age=\(seconds)"
            case .maxStale(let seconds):
                if let seconds = seconds {
                    return "max-stale=\(seconds)"
                } else {
                    return "max-stale"
                }
            case .minFresh(let seconds):
                return "min-fresh=\(seconds)"
        }
    }
}
