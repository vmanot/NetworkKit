//
// Copyright (c) Vatsal Manot
//

import API
import CombineX
import Foundation

public protocol HTTPRequestBuilder: RequestBuilder where Request == HTTPRequest {
    var host: URL { get }
    var path: String { get }
    
    var method: HTTPMethod { get }
    var query: HTTPRequest.Query { get }
    var body: HTTPRequest.Body { get }
    var header: HTTPRequest.Header { get }
}

// MARK: - Implementation -

extension HTTPRequestBuilder {
    public var query: HTTPRequest.Query {
        [:]
    }
    
    public var body: HTTPRequest.Body {
        Data()
    }
    
    public var header: HTTPRequest.Header {
        []
    }
    
    public func buildRequest() throws -> Request {
        HTTPRequest(url: host.appendingPathComponent(path))
            .method(method)
            .query(query)
            .body(body)
            .header(header)
    }
}

// MARK: - Implementation -

extension HTTPRequestBuilder where Self: CreateRequestBuilder {
    public var method: HTTPMethod {
        return .post
    }
}

extension HTTPRequestBuilder where Self: DeleteRequestBuilder {
    public var method: HTTPMethod {
        return .delete
    }
}

extension HTTPRequestBuilder where Self: GetRequestBuilder {
    public var method: HTTPMethod {
        return .get
    }
}

extension HTTPRequestBuilder where Self: SetRequestBuilder {
    public var method: HTTPMethod {
        return .put
    }
}

extension HTTPRequestBuilder where Self: UpdateRequestBuilder {
    public var method: HTTPMethod {
        return .put
    }
}

// MARK: - Helpers -

extension HTTPRequest: Request {
    
}
