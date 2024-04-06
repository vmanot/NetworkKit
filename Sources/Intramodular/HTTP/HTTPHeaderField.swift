//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum HTTPHeaderField: Hashable, Sendable {
    case accept(HTTPMediaType)
    case authorization(HTTPAuthorizationType, String)
    case cacheControl(HTTPCacheControlType)
    case connection(HTTPConnectionType)
    case contentDisposition(String)
    case contentLength(octets: Int)
    case contentType(HTTPMediaType)
    case cookie(String)
    case host(host: String, port: String)
    case location(URL)
    case origin(String)
    case referer(String)
    case userAgent(HTTPUserAgent)
    
    case custom(key: String, value: String)
    
    public static func custom(key: String, value: APIKey?) -> Self? {
        value.map({ Self.custom(key: key, value: $0.value) })
    }
    
    public init(key: String, value: String) {
        switch key {
            case Self.Key.accept.rawValue:
                self = .accept(.init(rawValue: value))
            case Self.Key.authorization.rawValue:
                self = .authorization(.init(rawValue: key), value)
            case Self.Key.cacheControl.rawValue:
                TODO.unimplemented
            case Self.Key.connection.rawValue:
                self = .connection(HTTPConnectionType(rawValue: value)!)
            case Self.Key.contentDisposition.rawValue:
                TODO.unimplemented
            case Self.Key.contentLength.rawValue:
                TODO.unimplemented
            case Self.Key.cookie.rawValue:
                self = .cookie(value)
            case Self.Key.contentType.rawValue:
                self = .contentType(.init(rawValue: value))
            case Self.Key.host.rawValue:
                self = .custom(key: HTTPHeaderField.Key.host.rawValue, value: value) // FIXME
            case Self.Key.location.rawValue:
                self = .location(URL(string: value)!)
            case Self.Key.origin.rawValue:
                self = .origin(value)
            case Self.Key.referer.rawValue:
                self = .referer(value)
            case Self.Key.userAgent.rawValue:
                self = .userAgent(HTTPUserAgent(rawValue: value))
                
            default:
                self = .custom(key: key, value: value)
        }
    }
    
    public init(key: AnyHashable, value: Any) {
        if let key = key.base as? String, let value = value as? String {
            self.init(key: key, value: value)
        } else {
            assertionFailure()
            
            self = .custom(key: String(describing: key), value: String(describing: value))
        }
    }
    
    public static func custom(key: String, value: String?) -> Self? {
        guard let value else {
            return nil
        }
        
        return .custom(key: key, value: value)
    }

}

extension HTTPHeaderField {
    public enum Key: Hashable {
        case accept
        case authorization
        case cacheControl
        case connection
        case contentDisposition
        case contentLength
        case contentType
        case cookie
        case host
        case location
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
                case .connection:
                    return "Connection"
                case .contentDisposition:
                    return "Content-Disposition"
                case .contentLength:
                    return "Content-Length"
                case .contentType:
                    return "Content-Type"
                case .cookie:
                    return "Cookie"
                case .host:
                    return "Host"
                case .location:
                    return "Location"
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
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue == rhs.rawValue
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
            case .connection:
                return .connection
            case .contentDisposition:
                return .contentDisposition
            case .contentLength:
                return .contentLength
            case .contentType:
                return .contentType
            case .cookie:
                return .cookie
            case .host:
                return .host
            case .location:
                return .location
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
            case .connection(let connectionType):
                return connectionType.rawValue
            case .contentDisposition(let value):
                return value
            case .contentLength(let length):
                return String(length)
            case .contentType(let contentType):
                return contentType.rawValue
            case .cookie(let value):
                return value
            case .host(let host, let port):
                return host + port
            case .location(let value):
                return value.absoluteString
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

// MARK: - Conformances

extension HTTPHeaderField: Codable {
    private struct _CodableRepresentation: Codable {
        let key: String
        let value: String
    }
    
    public init(from decoder: Decoder) throws {
        let keyValuePair = try decoder.singleValueContainer().decode(_CodableRepresentation.self)
        
        self.init(key: keyValuePair.key, value: keyValuePair.value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(_CodableRepresentation(key: key.rawValue, value: value))
    }
}

extension HTTPHeaderField: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(key.rawValue): \(value)"
    }
}

// MARK: - Helpers

extension Sequence where Element == HTTPHeaderField {
    public subscript(_ key: HTTPHeaderField.Key) -> String? {
        first(where: { $0.key == key })?.value
    }
}
