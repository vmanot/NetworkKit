//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import SwiftAPI

public protocol HTTPEndpointBuilderPropertyWrapper: EndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
    
}

public struct HTTPRequestBuilders {
    @propertyWrapper
    public struct SetHost<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
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
    public struct SetPath<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
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
    public struct SetAbsolutePath<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
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
    public struct SetMethod_DELETE<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.delete)
            }
        }
        
        public init(wrappedValue: Base, _ type: Base.Output.Type) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.delete)
            }
        }
        
        public init(wrappedValue: Base, _ type: Base.Output.Type) where Input == Void, Options == Void? {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.delete)
            }
        }
    }
    
    @propertyWrapper
    public struct SetMethod_GET<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
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
    public struct SetMethod_PATCH<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.patch)
            }
        }
    }
    
    
    @propertyWrapper
    public struct SetMethod_POST<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.post)
            }
        }
    }
    
    @propertyWrapper
    public struct SetMethod_PUT<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, _ in
                request.method(.put)
            }
        }
    }
    
    @propertyWrapper
    public struct AddQuery<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base, _ query: [URLQueryItem]) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(query)
            }
        }
        
        public init(
            wrappedValue: Base,
            _ query: [String: String]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(query)
            }
        }
        
        public init(
            wrappedValue: Base,
            _ query: [String: String?]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(query)
            }
        }
        
        public init(
            wrappedValue: Base,
            _ query: KeyPath<Input, [URLQueryItem]>
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(context.input[keyPath: query])
            }
        }
        
        public init(
            wrappedValue: Base,
            _ query: KeyPath<Input, String>
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(context.input[keyPath: query])
            }
        }
        
        public init(
            wrappedValue: Base,
            _ query: [String: KeyPath<Input, String>]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(query.mapValues({ context.input[keyPath: $0] }))
            }
        }
        
        public init(
            wrappedValue: Base,
            _ name: String,
            _ getQueryValue: KeyPath<Input, String>
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query([name: context.input[keyPath: getQueryValue]])
            }
        }
        
        public init(
            wrappedValue: Base,
            _ name: String,
            _ getQueryValue: KeyPath<Input, String?>
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query([name: context.input[keyPath: getQueryValue]])
            }
        }
        
        public init(
            wrappedValue: Base,
            _ name: String,
            fromContext keyPath: KeyPath<BuildRequestTransformContext, String?>
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query([name: context[keyPath: keyPath]])
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
                try request.jsonQuery(
                    context.input[keyPath: value],
                    dateEncodingStrategy: dateEncodingStrategy,
                    dataEncodingStrategy: dataEncodingStrategy,
                    keyEncodingStrategy: keyEncodingStrategy,
                    nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy
                )
            }
        }
        
        public init(
            wrappedValue: Base,
            _ value: @escaping (BuildRequestTransformContext) throws -> [URLQueryItem]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(try value(context))
            }
        }
        
        public init(
            wrappedValue: Base,
            _ value: @escaping (BuildRequestTransformContext) throws -> [String: String?]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(try value(context))
            }
        }
        
        public init(
            wrappedValue: Base,
            _ value: @escaping (Input) throws -> [String: String?]
        ) {
            self.init(wrappedValue: wrappedValue, { try value($0.input) })
        }
        
        public init(
            wrappedValue: Base,
            _ value: [String: KeyPath<BuildRequestTransformContext, String?>]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.query(value.mapValues({ context[keyPath: $0] }))
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
    public struct AddHeader<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public var wrappedValue: Base
        
        public init(wrappedValue: Base, _ headerField: HTTPHeaderField) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.header(headerField)
            }
        }
        
        public init(
            wrappedValue: Base,
            @ArrayBuilder _ makeHeader: @escaping (BuildRequestTransformContext) -> [HTTPHeaderField]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.header(makeHeader(context))
            }
        }
        
        public init(
            wrappedValue: Base,
            _ headers: [String: String]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                request.headers(headers)
            }
        }
    }
    
    @propertyWrapper
    public struct AddBody<Base: ModifiableEndpoint>: HTTPEndpointBuilderPropertyWrapper where Base.Root.Request == HTTPRequest {
        public enum _Token {
            case input
        }
        
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
        
        public init(
            wrappedValue: Base,
            json value: [String: Any]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(value)
            }
        }
        
        public init(
            wrappedValue: Base,
            json value: [String: KeyPath<Mirror.DynamicMemberLookup, Mirror.DynamicMemberLookup.Key>]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(value.compactMapValues({ Mirror(reflecting: context.input)[keyPath: $0] }))
            }
        }
        
        public init<T>(
            wrappedValue: Base,
            json value: [String: KeyPath<Input, T>]
        ) {
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
        
        public init<T: Encodable>(
            wrappedValue: Base,
            json value: @escaping (BuildRequestTransformContext) -> T,
            dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
            dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
            keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
            nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(
                    value(context),
                    dateEncodingStrategy: dateEncodingStrategy,
                    dataEncodingStrategy: dataEncodingStrategy,
                    keyEncodingStrategy: keyEncodingStrategy,
                    nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy
                )
            }
        }
        
        public init(
            wrappedValue: Base,
            json value: _Token,
            dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
            dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
            keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
            nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(
                    context.input,
                    dateEncodingStrategy: dateEncodingStrategy,
                    dataEncodingStrategy: dataEncodingStrategy,
                    keyEncodingStrategy: keyEncodingStrategy,
                    nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy
                )
            }
        }
        
        public init(
            wrappedValue: Base,
            multipart value: _Token
        ) where Base.Input: HTTPRequest.Multipart.ContentConvertible {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context -> HTTPRequest in
                let content: HTTPRequest.Multipart.Content = try context.input.__conversion()
                
                return request.body(content)
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
        
        public init(
            wrappedValue: Base,
            json value: @escaping (Input) -> [String: Any]
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.jsonBody(value(context.input))
            }
        }
        
        public init(
            wrappedValue: Base,
            json value: @escaping (Input) -> [String: Any?]
        ) {
            self.init(wrappedValue: wrappedValue, json: { value($0).compactMapValues({ $0 }) })
        }
        
        public init(
            wrappedValue: Base,
            _ value: @escaping (BuildRequestTransformContext) throws -> HTTPRequest.Body
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.body(value(context))
            }
        }

        public init(
            wrappedValue: Base,
            _ value: @escaping (BuildRequestTransformContext) throws -> HTTPRequest.Multipart.Content
        ) {
            self.wrappedValue = wrappedValue
            
            self.wrappedValue.addBuildRequestTransform { request, context in
                try request.body(value(context))
            }
        }
    }
}

extension HTTPAPISpecification {
    public typealias Host<Base: ModifiableEndpoint> = HTTPRequestBuilders.SetHost<Base> where Base.Root == Self
    public typealias Path<Base: ModifiableEndpoint> = HTTPRequestBuilders.SetPath<Base> where Base.Root == Self
    public typealias AbsolutePath<Base: ModifiableEndpoint> = HTTPRequestBuilders.SetAbsolutePath<Base> where Base.Root == Self
    public typealias DELETE<Base: ModifiableEndpoint> = HTTPRequestBuilders.SetMethod_DELETE<Base> where Base.Root == Self
    public typealias GET<Base: ModifiableEndpoint> = HTTPRequestBuilders.SetMethod_GET<Base> where Base.Root == Self
    public typealias PATCH<Base: ModifiableEndpoint> = HTTPRequestBuilders.SetMethod_PATCH<Base> where Base.Root == Self
    public typealias POST<Base: ModifiableEndpoint> = HTTPRequestBuilders.SetMethod_POST<Base> where Base.Root == Self
    public typealias PUT<Base: ModifiableEndpoint> = HTTPRequestBuilders.SetMethod_PUT<Base> where Base.Root == Self
    public typealias Query<Base: ModifiableEndpoint> = HTTPRequestBuilders.AddQuery<Base> where Base.Root == Self
    public typealias Header<Base: ModifiableEndpoint> = HTTPRequestBuilders.AddHeader<Base> where Base.Root == Self
    public typealias Body<Base: ModifiableEndpoint> = HTTPRequestBuilders.AddBody<Base> where Base.Root == Self
}
