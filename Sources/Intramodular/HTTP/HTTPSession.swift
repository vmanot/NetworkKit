//
// Copyright (c) Vatsal Manot
//

import API
import Foundation
import Merge
import Swift

public struct HTTPSession: RequestSession {
    public let cancellables = Cancellables()
    
    private let base: URLSession
    
    public func task(with request: HTTPRequest) -> AnyPublisher<HTTPRequest.Response, HTTPRequest.Error> {
        do {
            return try base.dataTaskPublisher(for: request)
                .map({ HTTPRequest.Response(data: $0.data, urlResponse: $0.response as! HTTPURLResponse) })
                .mapError(HTTPRequestError.init)
                .eraseToAnyPublisher()
        } catch {
            return .failure(HTTPRequestError.unknown)
        }
    }
}
