//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import Swallow
import SwiftAPI

public protocol HTTPEndpoint: Endpoint where Root: HTTPAPISpecification {
    
}

// MARK: - Conformances

@propertyWrapper
open class BaseHTTPEndpoint<Root: HTTPAPISpecification, Input, Output, Options>:
    ModifiableEndpointBase<Root, Input, Output, Options>, HTTPEndpoint {
    open override var wrappedValue: ModifiableEndpointBase<Root, Input, Output, Options> {
        self
    }
    
    override open func buildRequestBase(
        from input: Input,
        context: BuildRequestContext
    ) throws -> HTTPRequest {
        if let input = input as? HTTPRequestPopulator {
            return try input.populate(HTTPRequest(url: context.root.baseURL))
        } else {
            return HTTPRequest(url: context.root.baseURL)
        }
    }
    
    override open func decodeOutputBase(
        from response: HTTPResponse,
        context: DecodeOutputContext
    ) throws -> Output {
        if let outputType = Output.self as? HTTPResponseDecodable.Type {
            return try outputType.init(from: response) as! Output
        }
        
        try response.validate()
        
        return try super.decodeOutput(from: response, context: context)
    }
}
