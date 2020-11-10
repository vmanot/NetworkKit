//
// Copyright (c) Vatsal Manot
//

import API
import Swift

open class GenericHTTPEndpoint<Root: HTTPInterface, Input, Output>: GenericMutableEndpoint<Root, Input, Output> {
    override open func buildRequestBase(
        from input: Input,
        context: BuildRequestContext
    ) throws -> HTTPRequest {
        HTTPRequest(url: context.root.baseURL)
    }
    
    override open func decodeOutput(
        from response: HTTPResponse,
        context: DecodeOutputContext
    ) throws -> Output {
        try super.decodeOutput(from: response, context: context)
    }
}
