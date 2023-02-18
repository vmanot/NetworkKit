//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol HTTPResponseDecodable {
    init(from response: HTTPResponse) throws
}

// MARK: - Conformances

extension HTTPResponse: HTTPResponseDecodable {
    public init(from response: HTTPResponse) {
        self = response
    }
}

extension HTTPResponseStatusCode: HTTPResponseDecodable {
    public init(from response: HTTPResponse) {
        self = response.statusCode
    }
}
