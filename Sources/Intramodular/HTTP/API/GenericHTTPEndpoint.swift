//
// Copyright (c) Vatsal Manot
//

import API
import Swift

open class GenericHTTPEndpoint<Root: HTTPInterface, Input, Output>: GenericMutableEndpoint<Root, Input, Output> {
    override open func buildRequestBase(for root: Root, from: Input) throws -> HTTPRequest {
        HTTPRequest(url: root.baseURL)
    }
    
    override open func decodeOutput(from response: HTTPResponse) throws -> Output {
        try super.decodeOutput(from: response)
    }
}
