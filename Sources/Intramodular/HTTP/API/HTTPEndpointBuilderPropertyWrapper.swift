//
// Copyright (c) Vatsal Manot
//

import API
import Swallow

public protocol HTTPEndpointBuilderPropertyWrapper: EndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
}


public struct HTTPRequestBuilders {
    @propertyWrapper
    public struct SetMethod_GET<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addRequestTransform({ $0.method(.get) })
        }
    }
    
    @propertyWrapper
    public struct SetMethod_POST<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addRequestTransform({ $0.method(.post) })
        }
    }
    
    @propertyWrapper
    public struct AddQuery<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base, _ name: String, _ getQueryValue: KeyPath<Input, String?>) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addRequestTransform { input, request in
                request.query([name: input[keyPath: getQueryValue]])
            }
        }
        
        public init(wrappedValue: Base, _ name: String, _ getQueryValue: KeyPath<Input, String>) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addRequestTransform { input, request in
                request.query([name: input[keyPath: getQueryValue]])
            }
        }
        
        public init(wrappedValue: Base, _ query: [String: KeyPath<Input, String>]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addRequestTransform { input, request in
                request.query(query.mapValues({ input[keyPath: $0] }))
            }
        }
    }
    
    @propertyWrapper
    public struct AddHeader<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base, _ makeHeader: @escaping (Input) -> [HTTPHeaderField]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addRequestTransform { input, request in
                request.header(makeHeader(input))
            }
        }
        
        public init(wrappedValue: Base, _ headerField: HTTPHeaderField) {
            self.init(wrappedValue: wrappedValue, { _ in [headerField ]})
        }
    }
}

extension HTTPInterface {    
    public typealias GET<Base: MutableEndpoint> = HTTPRequestBuilders.SetMethod_GET<Base> where Base.Root == Self
    public typealias POST<Base: MutableEndpoint> = HTTPRequestBuilders.SetMethod_POST<Base> where Base.Root == Self
    public typealias Query<Base: MutableEndpoint> = HTTPRequestBuilders.AddQuery<Base> where Base.Root == Self
    public typealias Header<Base: MutableEndpoint> = HTTPRequestBuilders.AddHeader<Base> where Base.Root == Self
}
