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
    open func buildRequest(for root: Root, from input: Input) throws -> HTTPRequest {
        try input.populate(HTTPRequest(url: root.host))
    }
    
    open func decodeOutput(from response: HTTPResponse) throws -> Output {
        fatalError()
    }
    
    public init() {
        
    }
    
    public convenience init<E: EndpointDescriptor>(_: E.Type) where E.Input == Input, E.Output == Output {
        self.init()
    }
}
