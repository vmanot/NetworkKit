//
// Copyright (c) Vatsal Manot
//

import API
import Foundation
import Merge
import Swallow

public struct HTTPSession: Identifiable, Initiable, RequestSession {
    public let cancellables = Cancellables()
    public let id = UUID()

    private let base: URLSession
    
    public init() {
        self.base = URLSession(configuration: .default)
    }
    
    public func task(with request: HTTPRequest) -> AnyPublisher<HTTPRequest.Response, HTTPRequest.Error> {
        do {
            return try base.dataTaskPublisher(for: request)
                .map({ HTTPRequest.Response(data: $0.data, urlResponse: $0.response as! HTTPURLResponse) })
                .mapError(HTTPRequestError.system)
                .eraseToAnyPublisher()
        } catch {
            return .failure(HTTPRequestError.system(error))
        }
    }
}
