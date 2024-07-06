//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Foundation
import Merge

extension ServerSentEvents.EventSource {
    @frozen
    public enum ReadyState {
        case none
        case connecting
        case open
        case closed
        case shutdown
    }
    
    @frozen
    public enum Event: Hashable, Sendable {
        case error(AnyError)
        case message(ServerSentEvents.ServerMessage)
        case open
        case closed
        
        public var message: ServerSentEvents.ServerMessage? {
            get throws {
                switch self {
                    case .error(let error):
                        throw error
                    case .message(let message):
                        return message
                    case .open:
                        return nil
                    case .closed:
                        return nil
                }
            }
        }
    }
}

extension ServerSentEvents {
    public final class EventSource {
        private let taskQueue = TaskQueue()
        
        private static let defaultTimeoutInterval: TimeInterval = 300
        
        public private(set) var readyState: ReadyState = .none
        
        public let request: URLRequest
        
        private var events: ReplaySubject<Event, Never>! = nil
        
        public var maxRetryCount: Int
        public var retryDelay: Double
        
        private var urlSession: URLSession?
        private var dataTask: URLSessionDataTask?
        private var httpResponseErrorStatusCode: HTTPResponseStatusCode?
        
        private let messageParser: SSE._ServerMessageParser
        private let operationQueue: OperationQueue = withMutableScope(OperationQueue()) {
            $0.maxConcurrentOperationCount = 1
        }
        private var currentRetryCount: Int = 1
        
        private var urlSessionConfiguration: URLSessionConfiguration {
            let configuration = (urlSession?.configuration.copy() ?? URLSessionConfiguration.default.copy()) as! URLSessionConfiguration
            
            configuration.httpAdditionalHeaders = [
                HTTPHeaderField.Key.accept.rawValue: HTTPMediaType.eventStream.rawValue,
                HTTPHeaderField.Key.cacheControl.rawValue: HTTPCacheControlType.noCache.value,
                "Last-Event-Id": messageParser.lastMessageID
            ]
            
            configuration.timeoutIntervalForRequest = Self.defaultTimeoutInterval
            configuration.timeoutIntervalForResource = Self.defaultTimeoutInterval
            
            return configuration
        }
        
        private lazy var sessionDelegate = SessionDelegate(onEvent: { [weak self] event in
            guard let `self` = self else {
                runtimeIssue("Dropped SSE event")
                
                return
            }
            
            self.handleEvent(event)
        })
        
        public init(
            request: URLRequest,
            session: URLSession? = nil,
            messageParser: SSE._ServerMessageParser = .init(),
            maxRetryCount: Int = 3,
            retryDelay: Double = 1.0
        ) {
            self.request = request
            self.urlSession = session
            self.messageParser = messageParser
            self.maxRetryCount = maxRetryCount
            self.retryDelay = retryDelay
        }
    }
}

extension SSE.EventSource {
    public func connect() async {
        await taskQueue.waitForAll()
        
        guard readyState == .none || readyState == .connecting else {
            return
        }
        
        await taskQueue.perform {
            _connect()
        }
    }
    
    @_disfavoredOverload
    public func connect() {
        Task {
            await self.connect()
        }
    }
    
    @discardableResult
    private func _connect() -> ReplaySubject<Event, Never> {
        self.events = ReplaySubject(bufferSize: Int.max)
        
        let urlSession = self.urlSession ?? URLSession(
            configuration: urlSessionConfiguration,
            delegate: sessionDelegate,
            delegateQueue: operationQueue
        )
        
        self.urlSession = urlSession
        
        let dataTask = urlSession.dataTask(with: request)
        
        dataTask.delegate = sessionDelegate
        
        self.readyState = .connecting
        self.dataTask = dataTask
        
        dataTask.resume()
        
        return events!
    }
    
    fileprivate func handleEvent(
        _ event: ServerSentEvents.EventSource.SessionDelegate.Event
    ) {
        taskQueue.addTask {
            switch event {
                case let .dataTaskDidComplete(result):
                    await self._handleSessionDataTaskCompletion(result)
                case let .dataTaskDidReceiveResponse(response, completionHandler):
                    await self._handleSessionDataTaskResponse(response, completionHandler: completionHandler)
                case let .dataTaskDidReceiveData(data):
                    await self._handleSessionDataTaskData(from: data)
            }
        }
    }
    
    fileprivate func _handleSessionDataTaskCompletion(
        _ completion: Result<Void, Error>
    ) async {
        guard readyState != .closed else {
            await close()
            
            return
        }
        
        func retry() async throws -> Bool {
            guard currentRetryCount < maxRetryCount else {
                return false
                
            }
            currentRetryCount += 1
            
            try await Task.sleep(durationInSeconds: retryDelay)
            
            readyState = .connecting
            
            await connect()
            
            return true
        }
        
        switch completion {
            case .success:
                await close()
            case .failure(let error):
                runtimeIssue(error)
                
                _sendErrorEvent(with: error)
        }
    }
    
    fileprivate func _handleSessionDataTaskResponse(
        _ response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) async {
        guard readyState != .shutdown else {
            runtimeIssue("Cancelled.")
            
            completionHandler(.cancel)
            
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            runtimeIssue("Cancelled.")
            
            completionHandler(.cancel)
            
            return
        }
        
        guard httpResponse.statusCode != 204 else {
            readyState = .shutdown
            
            completionHandler(.cancel)
            
            await close()
            
            return
        }
        
        if 200...299 ~= httpResponse.statusCode {
            currentRetryCount = 1
            
            if readyState != .open {
                _setOpen()
            }
        } else {
            httpResponseErrorStatusCode = HTTPResponseStatusCode(from: httpResponse)
        }
        
        completionHandler(.allow)
    }
    
    public func close() async {
        await taskQueue.perform {
            let previousState = readyState
            
            readyState = .closed
            messageParser.reset()
            
            if previousState == .open {
                events.send(.closed)
                events.send(completion: .finished)
                events = nil
            }
            
            _tearDown()
        }
    }
    
    public func shutdown() {
        let previousState = readyState
        
        readyState = .shutdown
        messageParser.reset()
        
        if previousState == .open {
            events.send(.closed)
        }
        
        _tearDown()
    }
    
    private func _tearDown() {
        dataTask?.cancel()
        dataTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
    }
    
    private func _handleSessionDataTaskData(
        from data: Data
    ) async {
        if let httpResponseErrorStatusCode {
            self.httpResponseErrorStatusCode = nil
            
            await _handleSessionDataTaskCompletion(
                .failure(
                    SSE.EventSourceError.connectionError(statusCode: httpResponseErrorStatusCode, response: data)
                )
            )
            
            return
        }
        
        let messages = messageParser.parsed(from: data)
        
        for message in messages {
            events.send(.message(message))
        }
    }
    
    fileprivate func _setOpen() {
        readyState = .open
        
        events.send(.open)
    }
    
    fileprivate func _sendErrorEvent(with error: Error) {
        runtimeIssue(error)
        
        events.send(.error(AnyError(erasing: error)))
    }
}

// MARK: - Conformances

extension SSE.EventSource: Publisher {
    public typealias Output = SSE.EventSource.Event
    public typealias Failure = Never
    
    public func receive<S: Subscriber<SSE.EventSource.Event, Never>>(
        subscriber: S
    ) {
        taskQueue.addTask {
            if (readyState != .closed && readyState != .shutdown) {
                _connect()
            }
            
            events.receive(subscriber: subscriber)
        }
    }
}
