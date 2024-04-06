//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import Swallow
import SwiftAPI

public protocol HTTPAPISpecification: APISpecification where Request == HTTPRequest {
    var host: URL { get }
    var baseURL: URL { get }
}

public protocol RESTAPISpecification: HTTPAPISpecification, RESTfulInterface {
    
}

public protocol _RESTAPIConfiguration: Codable, Hashable, Sendable {
    
}

@available(*, deprecated, renamed: "HTTPAPISpecification")
public typealias HTTPInterface = HTTPAPISpecification
@available(*, deprecated, renamed: "RESTAPISpecification")
public typealias RESTfulHTTPInterface = RESTAPISpecification

// MARK: - Implementation

extension HTTPAPISpecification {
    public var baseURL: URL {
        host
    }
}
