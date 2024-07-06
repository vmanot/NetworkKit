//
// Copyright (c) Vatsal Manot
//

import Foundation

extension SSE {
    public enum EventSourceError: Error {
        case undefinedConnectionError
        case connectionError(statusCode: HTTPResponseStatusCode, response: Data)
    }
}
