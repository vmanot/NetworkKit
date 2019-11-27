//
// Copyright (c) Vatsal Manot
//

import API
import CombineX
import Data
import Foundation

public protocol CodableHTTPRequestCoordinator: HTTPRequestBuilder, RequestCoordinator where Self.Output: Decodable {
    
}

extension CodableHTTPRequestCoordinator {
    public func transform(_ response: HTTPRequest.Response) throws -> Output {
        try JSONDecoder().decode(Output.self, from: response.data)
    }
}


