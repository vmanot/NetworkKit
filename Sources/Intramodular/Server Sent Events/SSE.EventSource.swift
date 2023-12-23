//
// Copyright (c) Vatsal Manot
//

import AsyncAlgorithms
import Foundation
import Merge

extension ServerSentEvents {
    public final class EventSource {
        public enum ReadyState: Int {
            case none = -1
            case connecting = 0
            case open = 1
            case closed = 2
        }
        
        @frozen
        public enum Event: Hashable, Sendable {
            case error(AnyError)
            case message(ServerSentEvents.ServerMessage)
            case open
            case closed
        }
        
        private static let defaultTimeoutInterval: TimeInterval = 300
        
        public private(set) var readyState: ReadyState = .none
        
        public let request: URLRequest
        public let events: AsyncChannel<Event> = .init()
        
        public var maxRetryCount: Int
        public var retryDelay: Double
        
        private let messageParser: SSE._ServerMessageParser
        private var currentRetryCount: Int = 1
        
        private var urlSessionConfiguration: URLSessionConfiguration {
            let configuration = URLSessionConfiguration.default
            
            configuration.httpAdditionalHeaders = [
                HTTPHeaderField.Key.accept.rawValue: HTTPMediaType.eventStream.rawValue,
                HTTPHeaderField.Key.cacheControl.rawValue: HTTPCacheControlType.noStore.value,
                "Last-Event-ID": messageParser.lastMessageId
            ]
            
            configuration.timeoutIntervalForRequest = Self.defaultTimeoutInterval
            configuration.timeoutIntervalForResource = Self.defaultTimeoutInterval
            
            return configuration
        }
        
        private var urlSession: URLSession?
        private var dataTask: URLSessionDataTask?
        private var sessionDelegate = SessionDelegate()
        private var sessionDelegateTask: Task<Void, Error>?
        private var httpResponseErrorStatusCode: HTTPResponseStatusCode?
        
        public init(
            request: URLRequest,
            messageParser: SSE._ServerMessageParser = .init(),
            maxRetryCount: Int = 3,
            retryDelay: Double = 1.0
        ) {
            self.request = request
            self.messageParser = messageParser
            self.maxRetryCount = maxRetryCount
            self.retryDelay = retryDelay
        }
        
        public func connect() {
            guard readyState == .none || readyState == .connecting else {
                return
            }
            
            urlSession = URLSession(
                configuration: urlSessionConfiguration,
                delegate: sessionDelegate,
                delegateQueue: nil
            )
            dataTask = urlSession?.dataTask(with: request)
            
            handleDelegateUpdates()
            
            dataTask?.resume()
            readyState = .connecting
        }
        
        private func handleDelegateUpdates() {
            sessionDelegate.onEvent = { event in
                self.sessionDelegateTask = Task(priority: .high) {
                    switch event {
                        case let .didCompleteWithError(error):
                            await self.handleSessionError(error)
                        case let .didReceiveResponse(response, completionHandler):
                            await self.handleSessionResponse(response, completionHandler: completionHandler)
                        case let .didReceiveData(data):
                            await self.parseMessages(from: data)
                    }
                }
            }
        }
        
        private func handleSessionError(_ error: Error?) async {
            guard readyState != .closed else {
                await close()
                
                return
            }
            
            if let error {
                await _sendErrorEvent(with: error)
            }
            
            if currentRetryCount < maxRetryCount {
                currentRetryCount += 1
                
                try? await Task.sleep(durationInSeconds: retryDelay)
                
                connect()
            } else {
                await close()
            }
        }
        
        private func handleSessionResponse(
            _ response: URLResponse,
            completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
        ) async {
            guard readyState != .closed else {
                completionHandler(.cancel)
                
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.cancel)
                
                return
            }
            
            guard httpResponse.statusCode != 204 else {
                completionHandler(.cancel)
                
                await close()
                
                return
            }
            
            if 200...299 ~= httpResponse.statusCode {
                currentRetryCount = 1
                
                if readyState != .open {
                    await _setOpen()
                }
            } else {
                httpResponseErrorStatusCode = HTTPResponseStatusCode(from: httpResponse)
            }
            
            completionHandler(.allow)
        }
        
        public func close() async {
            let previousState = readyState
            
            readyState = .closed
            messageParser.reset()
            sessionDelegateTask?.cancel()
            sessionDelegateTask = nil
            dataTask?.cancel()
            dataTask = nil
            urlSession?.invalidateAndCancel()
            urlSession = nil
            
            if previousState == .open {
                await events.send(.closed)
            }
            
            events.finish()
        }
        
        private func parseMessages(from data: Data) async {
            if let httpResponseErrorStatusCode {
                self.httpResponseErrorStatusCode = nil
                
                await handleSessionError(
                    EventSourceError.connectionError(statusCode: httpResponseErrorStatusCode, response: data)
                )
                
                return
            }
            
            let messages = messageParser.parsed(from: data)
            
            await messages.enumerated().asyncForEach { (index, message) in
                if (index == messages.count - 1) && (message.data == "[DONE]") == true {
                    await close()
                } else {
                    await events.send(.message(message))
                }
            }
        }
        
        fileprivate func _setOpen() async {
            readyState = .open
            
            await events.send(.open)
        }
        
        fileprivate func _sendErrorEvent(with error: Error) async {
            await events.send(.error(AnyError(erasing: error)))
        }
    }
}

extension SSE.EventSource: Publisher {
    public typealias Output = SSE.EventSource.Event
    public typealias Failure = Never
    
    public func receive<S: Subscriber<SSE.EventSource.Event, Never>>(
        subscriber: S
    ) {
        let publisher = events
            .eraseToStream()
            .publisher()
        
        publisher.receive(subscriber: subscriber)
    }
}
