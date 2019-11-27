//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swift

/// An HTTP request.
public struct HTTPRequest {
    public typealias Query = [String: String?]
    public typealias Header = [HTTPHeaderComponent]
    public typealias Body = HTTPRequestBody
    public typealias Response = HTTPRequestResponse
    public typealias Error = HTTPRequestError
    
    public private(set) var url: URL
    public private(set) var method: HTTPMethod?
    public private(set) var query: Query = [:]
    public private(set) var header: Header = []
    public private(set) var body: HTTPRequestBody?
    
    public init(url: URL) {
        self.url = url
    }
}

extension HTTPRequest {
    public func method(_ method: HTTPMethod) -> HTTPRequest {
        var result = self
        
        result.method = method
        
        return result
    }
    
    public func query(_ query: Query) -> HTTPRequest {
        var result = self
        
        result.query = query
        
        return result
    }
    
    public func header(_ header: Header) -> HTTPRequest {
        var result = self
        
        result.header = header
        
        return result
    }
    
    public func body(_ body: HTTPRequestBody) -> HTTPRequest {
        var result = self
        
        result.body = body
        
        return result
    }
}

// MARK: - Helpers -

extension URLRequest {
    public init(_ request: HTTPRequest) throws {
        guard var components = URLComponents(url: request.url, resolvingAgainstBaseURL: true) else {
            fatalError()
        }
        
        components.queryItems = request.query.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        self.init(url: components.url!)
        
        httpMethod = request.method?.rawValue
        
        request.header.forEach { component in
            addValue(component.value, forHTTPHeaderField: component.key)
        }
        
        if let body = try request.body?.buildEntity() {
            switch body {
                case .data(let data):
                    httpBody = data
                case .inputStream(let stream):
                    httpBodyStream = stream
            }
        }
    }
}

extension URLSession {
    public func dataTaskPublisher(for request: HTTPRequest) throws -> DataTaskPublisher {
        try dataTaskPublisher(for: URLRequest(request))
    }
}
