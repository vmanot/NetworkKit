//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import Swallow
import SwiftAPI

public final class HTTPSession: Identifiable, Initiable, RequestSession, Sendable {
    public static let shared = HTTPSession(base: URLSession.shared)
    
    public let cancellables = Cancellables()
    public let id: UUID
    private let base: URLSession
    
    public var configuration: URLSessionConfiguration {
        base.configuration
    }
    
    public init(base: URLSession) {
        self.id = UUID()
        self.base = base
    }
    
    public convenience init() {
        self.init(base: .init(configuration: .default))
    }
    
    public func task(
        with request: HTTPRequest
    ) -> AnyTask<HTTPRequest.Response, HTTPRequest.Error> {
        do {
            if request.method == .get {
                assert(request.body == nil)
            }
            
            return try base
                .dataTaskPublisher(for: request)
                .map({ HTTPRequest.Response(data: $0.data, cocoaURLResponse: $0.response as! HTTPURLResponse) })
                .mapError({ HTTPRequest.Error.system(.init(erasing: $0)) })
                .convertToTask()
        } catch {
            return .failure(HTTPRequest.Error.system(.init(erasing: error)))
        }
    }
}

// MARK: - Conformances

extension HTTPSession: ObjectiveCBridgeable {
    public typealias _ObjectiveCType = URLSession
    
    public static func bridgeFromObjectiveC(_ source: ObjectiveCType) throws -> Self {
        .init(base: source)
    }
    
    public func bridgeToObjectiveC() throws -> ObjectiveCType {
        base
    }
}
