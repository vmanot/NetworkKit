//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol HTTPRequestBody {
    var header: [HTTPHeaderField] { get }
    
    func content() throws -> HTTPRequestBodyContent
}

// MARK: - Implementation -

extension HTTPRequestBody {
    public var header: [HTTPHeaderField] {
        return []
    }
}

// MARK: - Concrete Implementations -

extension Data: HTTPRequestBody {
    public func content() throws -> HTTPRequestBodyContent {
        return .data(self)
    }
}

// MARK: - Helpers -

extension HTTPRequest {
    public func jsonBody<T: Encodable>(_ value: T) throws -> Self {
        body(try JSONEncoder().encode(value))
    }
}
