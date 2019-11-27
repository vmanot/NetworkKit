//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPHeaderComponent {
    case accept(HTTPMediaType)
    case authorization(HTTPAuthorizationType, String)
    case cacheControl(HTTPCacheControlType)
    case contentLength(octets: Int)
    case contentType(HTTPMediaType)
    case host(host: String, port: String)
    case origin(String)
    case referer(String)
    case userAgent(HTTPUserAgent)

    public var key: String {
        switch self {
            case .accept:
                return "Accept"
            case .authorization:
                return "Authorization"
            case .cacheControl:
                return "Cache-Control"
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
        }
    }
}
