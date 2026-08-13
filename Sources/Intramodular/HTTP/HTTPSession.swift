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
    
    public static var localhost: HTTPSession {
        let result = HTTPSession(base: URLSession.shared)
        
        result._unsafeFlags.insert(.localhost)
        
        return result
    }

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
    
    public convenience init(host: URL) {
        self.init(base: .shared)
        
        self._unsafeFlags.insert(.host(host))
    }
    
    public func disableTimeouts() {
        lock.withCriticalScope {
            let sessionConfiguration = URLSessionConfiguration.default
            
            sessionConfiguration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
            sessionConfiguration.timeoutIntervalForResource = TimeInterval(INT_MAX)
            
            self.base = URLSession(configuration: sessionConfiguration)
        }
    }
    
    public convenience init() {
        self.init(base: .init(configuration: .default))
    }
    
    public func task(
        with request: HTTPRequest
    ) -> AnyTask<HTTPRequest.Response, HTTPRequest.Error> {
        if let host = _unsafeFlags.first(byUnwrapping: /_UnsafeFlag.host) {
            if !request.host.absoluteString.hasPrefix(host.absoluteString) {
                return .failure(.system(Never.Reason.illegal))
            }
        }
        
        return lock.withCriticalScope {
            if request.method == .get {
                assert(request.body == nil)
            }
            let urlSession: URLSession = base
            let dumpsResponseBodies: Bool = _unsafeFlags.contains(.dumpRequestBodies)
            return PassthroughTask<HTTPRequest.Response, HTTPRequest.Error> { task in
                let operation = _Concurrency.Task {
                    do {
                        let (data, urlResponse) = try await urlSession.data(for: request)
                        let response = HTTPRequest.Response(
                            request: request,
                            data: data,
                            cocoaURLResponse: try cast(urlResponse, to: HTTPURLResponse.self)
                        )
                        if dumpsResponseBodies {
                            #try(.optimistic) {
                                print(try JSON(data: data).prettyPrintedDescription)
                            }
                        }
                        task.succeed(with: response)
                    } catch {
                        task.fail(with: .system(AnyError(erasing: error)))
                    }
                }
                return AnyCancellable {
                    operation.cancel()
                }
            }
            .eraseToAnyTask()
        }
    }
}

extension HTTPSession {
    public func data(
        for request: URLRequest
    ) async throws -> HTTPResponse {
        let (data, response) = try await base.data(for: request)
        
        let result = try HTTPResponse(
            request: nil,
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
            request: request,
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
        case localhost
        case dumpRequestBodies
        case host(URL)
    }
}
