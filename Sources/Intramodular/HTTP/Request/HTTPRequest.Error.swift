//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension HTTPRequest {
    public enum Error: Swift.Error {
        case badRequest(HTTPResponse)
        case system(Swift.Error)
    }
}

// MARK: - Protocol Conformances -

extension HTTPRequest.Error: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
            case .badRequest(let response):
                return "Bad request: \(response.statusCode)"
            case .system(let error):
                return String(describing: error)
        }
    }
}
