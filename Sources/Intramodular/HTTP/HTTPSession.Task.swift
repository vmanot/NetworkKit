//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import Swallow
import SwiftAPI

extension HTTPSession {
    public final class Task: NSObject, Merge.ObservableTask, URLSessionTaskDelegate {
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
    
    public var objectDidChange: AnyPublisher<TaskStatus<Data, Error>, Never> {
        _statusSubject.eraseToAnyPublisher() // FIXME: !!!
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
    
    public func cancel() {
        base?.cancel()
        
        _statusSubject.send(.canceled)
    }
}
