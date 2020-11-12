//
// Copyright (c) Vatsal Manot
//

import API
import Foundation
import Merge
import Swift

public protocol HTTPEndpoint: Endpoint where Root: HTTPInterface, Input: HTTPRequestDescriptor {
    func path(from _: Input) -> String
}

// MARK: - Conformances -

open class BaseHTTPEndpoint<Root: HTTPInterface, Input, Output>:
    MutableEndpointBase<Root, Input, Output> {
    override open func buildRequestBase(
        from input: Input,
        context: BuildRequestContext
    ) throws -> HTTPRequest {
        if let input = input as? HTTPRequestDescriptor {
            return try input.populate(HTTPRequest(url: context.root.baseURL))
        } else {
            return HTTPRequest(url: context.root.baseURL)
        }
    }
    
    override open func decodeOutputBase(
        from response: HTTPResponse,
        context: DecodeOutputContext
    ) throws -> Output {
        try super.decodeOutput(from: response, context: context)
    }
}
