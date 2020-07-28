//
// Copyright (c) Vatsal Manot
//

import API
import Foundation
import Merge
import Swallow

public struct HTTPSession: Identifiable, Initiable, RequestSession {
    public let cancellables = Cancellables()
    
    public private(set) var id = UUID()
    
    private var base: URLSession {
        didSet {
            id = .init()
        }
    }
    
    public var configuration: URLSessionConfiguration {
        get {
            base.configuration
        } set {
            base = .init(configuration: newValue)
        }
    }
    
    public init() {
        self.base = URLSession(configuration: .default)
    }
    
    public func task(with request: HTTPRequest) -> AnyTask<HTTPRequest.Response, HTTPRequest.Error> {
        do {
            return try base.dataTaskPublisher(for: request)
                .map({ HTTPRequest.Response(data: $0.data, urlResponse: $0.response as! HTTPURLResponse) })
                .mapError(HTTPRequestError.system)
                .eraseToTask()
        } catch {
            return .failure(HTTPRequestError.system(error))
        }
    }
}
