# NetworkKit

NetworkKit is a networking library written in Swift. It offers the following:

- Idiomatic Swift types for representing HTTP requests and related data types.
- A type-safe [Retrofit](https://square.github.io/retrofit/) inspired DSL for declaring HTTP interfaces.
- Utilities to manipulate standard certificate formats used in secure telecommunication (ASN.1, PKCS 7, X509)
- Common implementations for custom framing protocols. 
- Extensions for the `NetworkExtension` framework.

## Declarative HTTP Interfaces

NetworkKit allows for powerful declarative composition of various kinds of HTTP interfaces.

A NetworkKit HTTP interface is fundamentally composed of the following:

- A base URL.
- A list of endpoints.
- A generic `Endpoint` class (inheriting from `BaseHTTPEndpoint`) responsible for configuring a generic HTTP request containing shared parameters (such as API keys etc.). 

Specific API endpoints by initializing the generic `Endpoint` class declared in the interface, and annotating them with NetworkKit provided decorators (i.e. property wrappers). The following decorators are supported:

-  `@Host(...)` 
- `@Path(...)`
- `@AbsolutePath(...)`
- `@DELETE`
- `@GET`
- `@PATCH`
- `@POST`
- `@PUT`
- `@Query(...)`
- `@Header(...)`
- `@Body(...)`

These decorators can be composed together to declare the configuration for an API endpoint. 

### Declaring a REST interface for GIPHY with NetworkKit

Here is a sample NetworkKit interface for the GIPHY API:

```swift
public struct GIPHY_API: RESTAPISpecification {
    public var apiKey: String
    public var host = URL(string: "https://api.giphy.com")!
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public var baseURL: URL {
        host.appendingPathComponent("/v1")
    }
    
    public var id: some Hashable {
        apiKey
    }
    
    @Path("gifs/search")
    @GET
    @Query({ context in
        return [
            "api_key": context.root.apiKey,
            "q": context.input.q,
            "limit": context.input.limit?.description
        ]
    })
    var search = Endpoint<RequestBodies.Search, ResponseBodies.Search, Void> ()
}

extension GIPHY_API {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<GIPHY_API, Input, Output, Options> {
        override public func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            let request = try super.buildRequestBase(from: input, context: context)
                .header(.accept(.json))
                .header(.contentType(.json))
            
            return request
        }
        
        override public func decodeOutputBase(
            from response: Request.Response,
            context: DecodeOutputContext
        ) throws -> Output {
            try response.validate()
            
            return try response.decode(Output.self, using: JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase))
        }
    }
}

extension GIPHY_API {
    public enum RequestBodies {
        public struct Search: Codable, Hashable {
            public var q: String
            public var limit: Int32?
            public var offset: Int?
            public var lang = "en"
        }
    }
    
    public enum ResponseBodies {
        public struct Search: Codable, Hashable {
            public struct Pagination: Codable, Hashable {
                public let offset: Int32
                public let totalCount: Int32
                public let count: Int32
            }
            
            public struct Meta: Codable, Hashable {
                public let msg: String
                public let status: HTTPResponseStatusCode
                public let responseId: String
            }
            
            public let data: [GIPHY_API.Schema.GIFObject]
            public let pagination: Pagination
            public let meta: Meta
        }
    }
}

extension GIPHY_API {
    public enum Schema {
        public struct GIFObject: Codable, Hashable {
            public struct Images: Codable, Hashable {
                public struct Downsized: Codable, Hashable {
                    public let url: URL
                    public let width: String
                    public let height: String
                    public let size: String
                }
                
                public let downsized: Downsized
            }
            
            public let type: String
            public let id: String
            public let slug: String
            public let url: URL
            public let bitlyUrl: URL?
            public let embedUrl: URL?
            public let username: String?
            public let source: String
            public let rating: String?
            // ...
            public let images: Images
            public let title: String
        }
    }
}
```

