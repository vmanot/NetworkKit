//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Merge
import Swallow
import SwiftAPI

public final class HTTPSession: Identifiable, Initiable, RequestSession, @unchecked Sendable {
    private let lock = OSUnfairLock()
    
    public static let shared = HTTPSession(base: URLSession.shared)
    
    public let cancellables = Cancellables()
    public let id: UUID
    public var _unsafeFlags: Set<_UnsafeFlag> = []
    
    private var base: URLSession
    
    public var configuration: URLSessionConfiguration {
        base.configuration
    }
    
    public init(base: URLSession) {
        self.id = UUID()
        self.base = base
    }
    
    public func disableTimeouts() {
        lock.withCriticalScope {
            let sessionConfiguration = URLSessionConfiguration.default
            
            sessionConfiguration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
            sessionConfiguration.timeoutIntervalForResource = TimeInterval(INT_MAX)
            
            self.base = URLSession(configuration: configuration)
        }
    }
    
    public convenience init() {
        self.init(base: .init(configuration: .default))
    }
    
    public func task(
        with request: HTTPRequest
    ) -> AnyTask<HTTPRequest.Response, HTTPRequest.Error> {
        lock.withCriticalScope {
            do {
                if request.method == .get {
                    assert(request.body == nil)
                }
                
                return try base
                    .dataTaskPublisher(for: request)
                    .map { [weak self] output -> HTTPRequest.Response in
                        let response = HTTPRequest.Response(
                            data: output.data,
                            cocoaURLResponse: output.response as! HTTPURLResponse
                        )
                        
                        if let `self` = self {
                            if self._unsafeFlags.contains(.dumpRequestBodies) {
                                #try(.optimistic) {
                                    let json = try JSON(data: output.data)
                                    
                                    print(json.prettyPrintedDescription)
                                }
                            }
                        }
                        
                        return response
                    }
                    .mapError {
                        HTTPRequest.Error.system(AnyError(erasing: $0))
                    }
                    .convertToTask()
            } catch {
                return .failure(HTTPRequest.Error.system(AnyError(erasing: error)))
            }
        }
    }
}

extension HTTPSession {
    public func data(
        for request: URLRequest
    ) async throws -> HTTPResponse {
        let (data, response) = try await base.data(for: request)
        
        let result = try HTTPResponse(
            data: data,
            cocoaURLResponse: cast(response, to: HTTPURLResponse.self)
        )
        
        return result
    }
    
    public func data(
        for request: HTTPRequest
    ) async throws -> HTTPResponse {
        let (data, response) = try await base.data(for: request)
        
        let result = try HTTPResponse(
            data: data,
            cocoaURLResponse: cast(response, to: HTTPURLResponse.self)
        )
        
        return result
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

// MARK: - Auxiliary

extension HTTPSession {
    public enum _UnsafeFlag: Codable, Hashable, Sendable {
        case dumpRequestBodies
    }
}
