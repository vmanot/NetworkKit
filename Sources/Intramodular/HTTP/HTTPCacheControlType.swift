//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPCacheControlType: Hashable, RawRepresentable, Sendable {
    case noCache
    case noStore
    case noTransform
    case onlyIfCached
    case maxAge(seconds: Int)
    case maxStale(seconds: Int?)
    case minFresh(seconds: Int)
    
    public var rawValue: String {
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
    
    public init?(rawValue: String) {
        let components = rawValue.lowercased().split(separator: "=")
        let directive = components[0].trimmingCharacters(in: .whitespaces)
        
        switch directive {
            case "no-cache":
                self = .noCache
            case "no-store":
                self = .noStore
            case "no-transform":
                self = .noTransform
            case "only-if-cached":
                self = .onlyIfCached
            case "max-age":
                guard components.count == 2, let seconds = Int(components[1]) else { return nil }
                self = .maxAge(seconds: seconds)
            case "max-stale":
                if components.count == 1 {
                    self = .maxStale(seconds: nil)
                } else if components.count == 2, let seconds = Int(components[1]) {
                    self = .maxStale(seconds: seconds)
                } else {
                    return nil
                }
            case "min-fresh":
                guard components.count == 2, let seconds = Int(components[1]) else { return nil }
                self = .minFresh(seconds: seconds)
            default:
                return nil
        }
    }
}
