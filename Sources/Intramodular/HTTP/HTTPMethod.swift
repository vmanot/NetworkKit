//
// Copyright (c) Vatsal Manot
//

import Swift

/// An HTTP method.
public enum HTTPMethod: String {
    case connect = "CONNECT"
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case trace = "TRACE"
    
    public var prefersQueryParameters: Bool {
        switch self {
            case .get, .head, .delete:
                return true
            default:
                return false
        }
    }
}
