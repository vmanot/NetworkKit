//
// Copyright (c) Vatsal Manot
//

import API
import Foundation
import Merge
import Swallow

extension HTTPSession {
    public final class Task: NSObject, Merge.Task, URLSessionTaskDelegate {
        public typealias Success = Data
        public typealias Error = Swift.Error
        public typealias Status = TaskStatus<Data, Error>
        
        private var base: URLSessionTask?
        
        public let request: HTTPRequest
        public let session: HTTPSession
        
        private let _statusSubject = CurrentValueSubject<Status, Never>(.idle)
        
        public init(request: HTTPRequest, session: HTTPSession) {
            self.request = request
            self.session = session
        }
    }
}

extension HTTPSession.Task {
    public var status: Status {
        _statusSubject.value
    }
    
    public var objectWillChange: AnyPublisher<TaskStatus<Data, Error>, Never> {
        _statusSubject.eraseToAnyPublisher()
    }
    
    public var taskIdentifier: TaskIdentifier {
        .init()
    }
    
    public var progress: Progress {
        base?.progress ?? .init()
    }
    
    public func start() {
        do {
            let dataTask = try session.bridgeToObjectiveC().dataTask(with: .init(request))
            
            dataTask.resume()
            
            self.base = dataTask
            
            _statusSubject.send(.active)
        } catch {
            _statusSubject.send(.error(error))
        }
    }
    
    public func pause() throws {
        base?.suspend()
        
        _statusSubject.send(.paused)
    }
    
    public func resume() throws {
        base?.resume()
        
        _statusSubject.send(.active)
    }
    
    public func cancel() {
        base?.cancel()
        
        _statusSubject.send(.canceled)
    }
}
