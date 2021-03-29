//
// Copyright (c) Vatsal Manot
//

import API
import Combine
import Foundation
import Swift

/// An HTTP request.
public struct HTTPRequest: Codable, Request {
    public typealias Method = HTTPMethod
    public typealias Query = [URLQueryItem]
    public typealias Header = [HTTPHeaderField]
    public typealias Response = HTTPResponse
    
    public private(set) var host: URL
    public private(set) var path: String?
    public private(set) var `protocol`: HTTPProtocol = .https
    public private(set) var method: HTTPMethod?
    public private(set) var query: Query = []
    public private(set) var header: Header = []
    public private(set) var body: Body?
    public private(set) var httpShouldHandleCookies: Bool = true
    
    public var url: URL {
        guard let path = path else {
            return host
        }
        
        return host.appendingPathComponent(path)
    }
    
    public init(url: URL) {
        self.host = url
    }
    
    public init!(url string: String) {
        guard let url = URL(string: string) else {
            return nil
        }
        
        self.host = url
    }
}

extension HTTPRequest {
    public func host(_ host: URL) -> Self {
        then({ $0.host = host })
    }
    
    public func path(_ path: String) -> Self {
        then({ $0.path = path })
    }
    
    public func absolutePath(_ path: String) -> Self {
        then {
            $0.host = URL(string: path)!
            $0.path = nil
        }
    }
    
    public func absolutePath(_ url: URL) -> Self {
        then {
            $0.host = url
            $0.path = nil
        }
    }
    
    public func `protocol`(_ protocol: HTTPProtocol) -> Self {
        then({ $0.protocol = `protocol` })
    }
    
    public func method(_ method: HTTPMethod) -> Self {
        then({ $0.method = method })
    }
    
    public func query(_ items: [URLQueryItem]) -> Self {
        then({ $0.query.append(contentsOf: items) })
    }
    
    public func query(_ query: [String: String?]) -> Self {
        then({ $0.query.append(contentsOf: query.map({ URLQueryItem(name: $0.key, value: $0.value) })) })
    }
    
    public func query(_ queryString: String) -> Self {
        query(
            queryString.components(separatedBy: "&").map { pair -> URLQueryItem in
                let value = pair
                    .components(separatedBy:"=")[1]
                    .replacingOccurrences(of: "+", with: " ")
                    .removingPercentEncoding ?? ""
                
                return URLQueryItem(name: pair.components(separatedBy: "=")[0], value: value)
            }
        )
    }
    
    public func header(_ header: Header) -> Self {
        then({ $0.header.append(contentsOf: header) })
    }
    
    public func header(_ field: HTTPHeaderField) -> Self {
        then({ $0.header.append(field) })
    }
    
    public func body(_ body: HTTPRequest.Body) -> Self {
        then {
            $0.body = body
            
            if $0.method == nil {
                $0.method = .post
            }
        }
    }
    
    public func body(_ data: Data) -> Self {
        body(HTTPRequest.Body(header: [], content: .data(data)))
    }
    
    public func httpShouldHandleCookies(_ httpShouldHandleCookies: Bool) -> Self {
        then({ $0.httpShouldHandleCookies = httpShouldHandleCookies })
    }
}

// MARK: - Conformances -

extension HTTPRequest: RequestBuilder {
    public func buildRequest(with _: Void) -> Self {
        self
    }
}

// MARK: - Auxiliary Implementation -

extension URLRequest {
    public init(_ request: HTTPRequest) throws {
        guard var components = URLComponents(url: request.url, resolvingAgainstBaseURL: true) else {
            fatalError()
        }
        
        if !request.query.isEmpty {
            if components.queryItems == nil {
                components.queryItems = []
            }
            
            components.queryItems?.append(contentsOf: request.query)
        }
        
        self.init(url: components.url!)
        
        httpMethod = request.method?.rawValue
        httpShouldHandleCookies = request.httpShouldHandleCookies
        
        request.header.forEach { component in
            addValue(component.value, forHTTPHeaderField: component.key.rawValue)
        }
        
        request.body?.header.forEach { component in
            addValue(component.value, forHTTPHeaderField: component.key.rawValue)
        }
        
        if let body = request.body?.content {
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

// MARK: - Helpers -

extension HTTPRequest {
    private func then(_ f: ((inout Self) throws -> Void)) rethrows -> Self {
        var result = self
        try f(&result)
        return result
    }
}
