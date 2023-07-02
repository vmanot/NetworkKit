//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

extension HTTPRequest {
    public enum Error: _ErrorX {
        case badRequest(HTTPResponse)
        case system(AnyError)
        
        public var traits: ErrorTraits {
            let base: ErrorTraits =  [.domain(.networking)]
            
            switch self {
                case .badRequest:
                    return base // FIXME!
                case .system(let error):
                    return base + error.traits
            }
        }
        
        public init?(_catchAll error: AnyError) throws {
            self = .system(error)
        }
    }
}

// MARK: - Conformances

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
