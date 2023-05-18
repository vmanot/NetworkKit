//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import Swallow
import SwiftAPI

public protocol HTTPInterface: ProgramInterface where Request == HTTPRequest {
    var host: URL { get }
    var baseURL: URL { get }
}

public protocol RESTfulHTTPInterface: HTTPInterface, RESTfulInterface {
    
}

// MARK: - Implementation

extension HTTPInterface {
    public var baseURL: URL {
        host
    }
}
