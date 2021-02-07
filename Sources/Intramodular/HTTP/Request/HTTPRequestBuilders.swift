//
// Copyright (c) Vatsal Manot
//

import API
import Swallow

public protocol HTTPEndpointBuilderPropertyWrapper: EndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
    
}

public struct HTTPRequestBuilders {
    @propertyWrapper
    public struct SetHost<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base, _ host: URL) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.host(request.host)
            }
        }
        
        public init(
            wrappedValue: Base,
            _ value: @escaping (BuildRequestTransformContext) throws -> URL
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.host(try value(context))
            }
        }
    }
    
    @propertyWrapper
    public struct SetPath<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base, _ path: String) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.path(path)
            }
        }
        
        public init(
            wrappedValue: Base,
            _ value: @escaping (BuildRequestTransformContext) throws -> String
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.path(try value(context))
            }
        }
    }
    
    @propertyWrapper
    public struct SetAbsolutePath<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base, _ path: String) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.absolutePath(path)
            }
        }
        
        public init(
            wrappedValue: Base,
            fromContext value: @escaping (BuildRequestTransformContext) throws -> String
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.absolutePath(try value(context))
            }
        }
        
        public init(
            wrappedValue: Base,
            fromContext value: @escaping (BuildRequestTransformContext) throws -> URL
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.absolutePath(try value(context))
            }
        }
    }
    
    @propertyWrapper
    public struct SetMethod_GET<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.get)
            }
        }
        
        public init(wrappedValue: Base, _ type: Base.Output.Type) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.get)
            }
        }
        
        public init(wrappedValue: Base, _ type: Base.Output.Type) where Input == Void, Options == Void? {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.get)
            }
        }
    }
    
    @propertyWrapper
    public struct SetMethod_PATCH<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.patch)
            }
        }
    }
    
    
    @propertyWrapper
    public struct SetMethod_POST<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.post)
            }
        }
    }
    
    @propertyWrapper
    public struct AddQuery<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base, _ query: [URLQueryItem]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(query)
            }
        }

        public init(wrappedValue: Base, _ query: KeyPath<Input, [URLQueryItem]>) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(context.input[keyPath: query])
            }
        }
        
        public init(wrappedValue: Base, _ query: KeyPath<Input, String>) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(context.input[keyPath: query])
            }
        }
        
        public init(wrappedValue: Base, _ query: [String: KeyPath<Input, String>]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(query.mapValues({ context.input[keyPath: $0] }))
            }
        }
        
        public init(wrappedValue: Base, _ name: String, _ getQueryValue: KeyPath<Input, String>) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query([name: context.input[keyPath: getQueryValue]])
            }
        }
        
        public init(wrappedValue: Base, _ name: String, _ getQueryValue: KeyPath<Input, String?>) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query([name: context.input[keyPath: getQueryValue]])
            }
        }
        
        public init(wrappedValue: Base, _ name: String, fromContext keyPath: KeyPath<BuildRequestTransformContext, String?>) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query([name: context[keyPath: keyPath]])
            }
        }
        
        public init(
            wrappedValue: Base,
            _ name: String,
            value: @escaping (BuildRequestTransformContext) throws -> String
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query([name: try value(context)])
            }
        }
        
        public init(
            wrappedValue: Base,
            _ name: String,
            value: @escaping (BuildRequestTransformContext) throws -> String?
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query([name: try value(context)])
            }
        }
    }
    
    @propertyWrapper
    public struct AddHeader<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base, _ headerField: HTTPHeaderField) {
            self.init(wrappedValue: wrappedValue, { _ in [headerField ]})
        }
        
        public init(wrappedValue: Base, _ makeHeader: @escaping (Input) -> [HTTPHeaderField]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.header(makeHeader(context.input))
            }
        }
    }
    
    @propertyWrapper
    public struct AddBody<Base: MutableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init<T: Encodable>(
            wrappedValue: Base,
            json value: T,
            dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
            dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
            keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
            nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(
                    value,
                    dateEncodingStrategy: dateEncodingStrategy,
                    dataEncodingStrategy: dataEncodingStrategy,
                    keyEncodingStrategy: keyEncodingStrategy,
                    nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy
                )
            }
        }
        
        public init(wrappedValue: Base, json value: [String: Any]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(value)
            }
        }
        
        public init(wrappedValue: Base, json value: [String: KeyPath<Mirror.DynamicMemberLookup, Mirror.DynamicMemberLookup.Key>]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(value.compactMapValues({ Mirror(reflecting: context.input)[keyPath: $0] }))
            }
        }
        
        public init<T>(wrappedValue: Base, json value: [String: KeyPath<Input, T>]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(value.compactMapValues({ context.input[keyPath: $0] }))
            }
        }
        
        public init<T: Encodable>(
            wrappedValue: Base,
            json value: KeyPath<Input, T>,
            dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
            dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
            keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
            nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(
                    context.input[keyPath: value],
                    dateEncodingStrategy: dateEncodingStrategy,
                    dataEncodingStrategy: dataEncodingStrategy,
                    keyEncodingStrategy: keyEncodingStrategy,
                    nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy
                )
            }
        }
        
        public init<T0, T1, T2>(
            wrappedValue: Base,
            json key0: String,
            _ value0: KeyPath<Input, T0>,
            _ key1: String,
            _ value1: KeyPath<Input, T1>,
            _ key2: String,
            _ value2: KeyPath<Input, T2>
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                var payload: [String: Any] = [:]
                
                payload[key0] = context.input[keyPath: value0]
                payload[key1] = context.input[keyPath: value1]
                payload[key2] = context.input[keyPath: value2]
                
                return try request.jsonBody(payload)
            }
        }
        
        public init(wrappedValue: Base, json value: @escaping (Input) -> [String: Any]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(value(context.input))
            }
        }
        
        public init(wrappedValue: Base, json value: @escaping (Input) -> [String: Any?]) {
            self.init(wrappedValue: wrappedValue, json: { value($0).compactMapValues({ $0 }) })
        }
    }
}

extension HTTPInterface {
    public typealias Host<Base: MutableEndpoint> = HTTPRequestBuilders.SetHost<Base> where Base.Root == Self
    public typealias Path<Base: MutableEndpoint> = HTTPRequestBuilders.SetPath<Base> where Base.Root == Self
    public typealias AbsolutePath<Base: MutableEndpoint> = HTTPRequestBuilders.SetAbsolutePath<Base> where Base.Root == Self
    public typealias GET<Base: MutableEndpoint> = HTTPRequestBuilders.SetMethod_GET<Base> where Base.Root == Self
    public typealias PATCH<Base: MutableEndpoint> = HTTPRequestBuilders.SetMethod_PATCH<Base> where Base.Root == Self
    public typealias POST<Base: MutableEndpoint> = HTTPRequestBuilders.SetMethod_POST<Base> where Base.Root == Self
    public typealias Query<Base: MutableEndpoint> = HTTPRequestBuilders.AddQuery<Base> where Base.Root == Self
    public typealias Header<Base: MutableEndpoint> = HTTPRequestBuilders.AddHeader<Base> where Base.Root == Self
    public typealias Body<Base: MutableEndpoint> = HTTPRequestBuilders.AddBody<Base> where Base.Root == Self
}
