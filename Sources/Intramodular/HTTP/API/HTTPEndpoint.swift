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

open class BaseHTTPEndpoint<Input: HTTPRequestDescriptor, Output, Root: HTTPInterface>: Endpoint {
    public typealias Request = Root.Request
    
    public typealias BuildRequestContext = EndpointBuildRequestContext<Root, Input, Output>
    public typealias DecodeOutputContext = EndpointDecodeOutputContext<Root, Input, Output>

    open func buildRequest(
        from input: Input,
        context: BuildRequestContext
    ) throws -> HTTPRequest {
        try input.populate(HTTPRequest(url: context.root.host))
    }
    
    open func decodeOutput(
        from response: HTTPResponse,
        context: DecodeOutputContext
    ) throws -> Output {
        fatalError()
    }
    
    public init() {
        
    }
    
    public convenience init<E: EndpointDescriptor>(_: E.Type) where E.Input == Input, E.Output == Output {
        self.init()
    }
}
