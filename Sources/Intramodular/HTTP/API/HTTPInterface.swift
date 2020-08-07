//
// Copyright (c) Vatsal Manot
//

import API
import Foundation
import Merge
import Swift

public protocol HTTPInterface: ProgramInterface where Request == HTTPRequest {
    var host: URL { get }
    var baseURL: URL { get }
}

public protocol RESTfulHTTPInterface: HTTPInterface, RESTfulInterface {
    
}

// MARK: - Implementation -

extension HTTPInterface {
    public var baseURL: URL {
        host
    }
}
