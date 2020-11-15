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
