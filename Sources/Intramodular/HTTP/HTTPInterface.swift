//
// Copyright (c) Vatsal Manot
//

import API
import Foundation
import Merge
import Swift

public protocol HTTPInterface: ApplicationProgramInterface where Request == HTTPRequest {
    var host: URL { get }
}

public protocol RESTfulHTTPInterface: HTTPInterface {
    
}
