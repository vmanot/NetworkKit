//
// Copyright (c) Vatsal Manot
//

import API
import Combine
import Foundation
import Swift

/// An HTTP request.
public struct HTTPRequest: Request {
    public typealias Query = [String: String?]
    public typealias Header = [HTTPHeaderField]
    public typealias Body = HTTPRequestBody
    public typealias Response = HTTPResponse
    public typealias Error = HTTPRequestError
    
    public private(set) var url: URL
    public private(set) var method: HTTPMethod?
    public private(set) var query: Query = [:]
    public private(set) var header: Header = []
    public private(set) var body: HTTPRequestBody?
    public private(set) var httpShouldHandleCookies: Bool = true
    
    public var wrappedValue: Self {
        self
    }
    
    public init(url: URL) {
        self.url = url
    }
    
    public init!(url string: String) {
        guard let url = URL(string: string) else {
            return nil
        }
        
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
    
    public func body(_ body: HTTPRequestBody?) -> HTTPRequest {
        var result = self
        
        result.body = body
        
        return result
    }
    
    public func httpShouldHandleCookies(_ httpShouldHandleCookies: Bool) -> HTTPRequest {
        var result = self
        
        result.httpShouldHandleCookies = httpShouldHandleCookies
        
        return result
    }
}

// MARK: - Protocol Implementations -

extension HTTPRequest: RequestBuilder {
    public func buildRequest(with _: Void) -> Self {
        self
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
        httpShouldHandleCookies = request.httpShouldHandleCookies
        
        request.header.forEach { component in
            addValue(component.value, forHTTPHeaderField: component.key.rawValue)
        }
        
        request.body?.requiredHeaderComponents.forEach { component in
            addValue(component.value, forHTTPHeaderField: component.key.rawValue)
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
