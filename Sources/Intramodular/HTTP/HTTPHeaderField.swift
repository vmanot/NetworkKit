//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPHeaderField: Hashable {
    case accept(HTTPMediaType)
    case authorization(HTTPAuthorizationType, String)
    case cacheControl(HTTPCacheControlType)
    case contentLength(octets: Int)
    case contentType(HTTPMediaType)
    case host(host: String, port: String)
    case origin(String)
    case referer(String)
    case userAgent(HTTPUserAgent)
    
    case custom(key: String, value: String)
}

extension HTTPHeaderField {
    public enum Key: Hashable {
        case accept
        case authorization
        case cacheControl
        case contentDisposition
        case contentLength
        case contentType
        case host
        case origin
        case referer
        case userAgent
        
        case custom(String)
        
        public var rawValue: String {
            switch self {
                case .accept:
                    return "Accept"
                case .authorization:
                    return "Authorization"
                case .cacheControl:
                    return "Cache-Control"
                case .contentDisposition:
                    return "Content-Disposition"
                case .contentLength:
                    return "Content-Length"
                case .contentType:
                    return "Content-Type"
                case .host:
                    return "Host"
                case .origin:
                    return "Origin"
                case .referer:
                    return "Referer"
                case .userAgent:
                    return "UserAgent"
                
                case let .custom(value):
                    return value
            }
        }
    }
}

extension HTTPHeaderField {
    public var key: HTTPHeaderField.Key {
        switch self {
            case .accept:
                return .accept
            case .authorization:
                return .authorization
            case .cacheControl:
                return .cacheControl
            case .contentLength:
                return .contentLength
            case .contentType:
                return .contentType
            case .host:
                return .host
            case .origin:
                return .origin
            case .referer:
                return .referer
            case .userAgent:
                return .userAgent
            case let .custom(key, _):
                return .custom(key)
        }
    }
    
    public var value: String {
        switch self {
            case .accept(let mediaType):
                return mediaType.rawValue
            case .authorization(let type, let credentials):
                return "\(type.rawValue) \(credentials)"
            case .cacheControl(let policy):
                return policy.value
            case .contentLength(let length):
                return String(length)
            case .contentType(let contentType):
                return contentType.rawValue
            case .host(let host, let port):
                return host + port
            case .origin(let origin):
                return origin
            case .referer(let referer):
                return referer
            case .userAgent(let userAgent):
                return userAgent.rawValue
            case let .custom(_, value):
                return value
        }
    }
}
