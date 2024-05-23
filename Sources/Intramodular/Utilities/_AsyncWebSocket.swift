//
// Copyright (c) Vatsal Manot
//

import Combine
import FoundationX
import Merge
import Swallow

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public actor _AsyncWebSocket {
    public typealias Message = URLSessionWebSocketTask.Message
    
    public enum State {
        case notConnected, connecting, connected, disconnected
    }
    
    private let queue = TaskQueue()
    
    private(set) var state: State = .notConnected
    
    public let messages: AsyncThrowingStream<Message, Swift.Error>
    
    private let urlRequest: URLRequest
    private let urlSession: URLSession
    private var socketTask: URLSessionWebSocketTask?
    private var socketTaskDelegate: SocketTaskDelegate?
    private var messagesContinuation: AsyncThrowingStream<Message, Swift.Error>.Continuation!
    
    public init(
        request: URLRequest,
        urlSession: URLSession = URLSession.shared
    ) {
        self.urlRequest = request
        self.urlSession = urlSession
        
        let (stream, continuation) = AsyncThrowingStream.makeStream(
            of: Message.self,
            throwing: Swift.Error.self
        )
        
        self.messages = stream
        self.messagesContinuation = continuation
    }
    
    public init(
        url: URL,
        urlSession: URLSession = URLSession.shared
    ) {
        self.init(request: URLRequest(url: url), urlSession: urlSession)
    }
    
    deinit {
        Task {
            try await _disconnect()
        }
    }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension _AsyncWebSocket {
    public func connect() async throws {
        try await queue.perform {
            await Result {
                try await self._connect()
            }
        }
        .get()
    }
    
    public func send(_ string: String) async throws {
        try await send(.string(string))
    }
    
    public func send(_ data: Data) async throws {
        try await send(.data(data))
    }
    
    public func send<Encoder>(
        _ value: any Encodable,
        encoder: Encoder
    ) async throws where Encoder: TopLevelEncoder, Encoder.Output == Data {
        let data = try encoder.encode(value)
        
        try await send(.data(data))
    }
    
    public func disconnect() async throws {
        try await queue.perform {
            await Result {
                try await self._disconnect()
            }
        }
        .get()
    }
    
    public func queue<T>(
        @_implicitSelfCapture operation: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        if state == .connecting {
            await queue.waitForAll()
        }
        
        return try await queue.perform { () -> Result<T, Swift.Error> in
            await Result {
                if await self.state == .notConnected {
                    try await self._connect()
                }
                
                return try await operation()
            }
        }
        .get()
    }
    
    private func _connect() async throws {
        state = .connecting
        
        await withCheckedContinuation { continuation in
            let delegate = SocketTaskDelegate { _ in
                Task {
                    self._setState(.connected)
                    
                    continuation.resume()
                    
                    self.receive()
                }
            } onTaskClose: { _, _ in
                self.handleDisconnection(withError: nil)
            } onTaskCompletionWithError: { error in
                self.handleDisconnection(withError: error)
            }
            
            self.socketTaskDelegate = delegate
            
            socketTask = urlSession.webSocketTask(with: urlRequest)
            socketTask?.delegate = delegate
            socketTask?.resume()
        }
    }
    
    private func _disconnect() throws {
        guard state == .connected else {
            throw Error.notConnected
        }
        
        messagesContinuation.finish()
        
        #try(.optimistic) {
            try socketTask.unwrap().cancel(with: .normalClosure, reason: nil)
            
            socketTask = nil
            socketTaskDelegate = nil
        }
    }
    
    
    private func _setState(_ state: State) {
        self.state = state
    }
    
    // MARK: - Private
    
    private func send(
        _ message: URLSessionWebSocketTask.Message
    ) async throws {
        guard state == .connected else {
            throw Error.notConnected
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Swift.Error>) in
            socketTask?.send(message) { error in
                if let error {
                    continuation.resume(with: .failure(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func receive() {
        #try(.optimistic) {
            try socketTask.unwrap().receive { [weak self] result in
                guard let _self = self else {
                    return
                }
                
                Task {
                    await _self.receive(result)
                }
            }
        }
    }
    
    private func receive(
        _ result: Result<Message, Swift.Error>
    ) {
        switch result {
            case .success(.data(let data)):
                messagesContinuation.yield(.data(data))
                receive()
            case .success(.string(let string)):
                messagesContinuation.yield(.string(string))
                receive()
            case .failure(let error):
                messagesContinuation.finish(throwing: error)
            default:
                assertionFailure()
                
                print(result)
        }
    }
    
    private func handleDisconnection(
        withError error: Swift.Error?
    ) {
        state = .disconnected
        
        messagesContinuation.finish(throwing: error)
        
        socketTask = nil
        socketTaskDelegate = nil
    }
}

// MARK: - Auxiliary

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension _AsyncWebSocket {
    private class SocketTaskDelegate: NSObject, URLSessionWebSocketDelegate {
        private let onTaskOpen: (_ protocol: String?) -> Void
        private let onTaskClose: (_ code: URLSessionWebSocketTask.CloseCode, _ reason: Data?) -> Void
        private let onTaskCompletionWithError: (_ error: Swift.Error?) -> Void
        
        init(
            onTaskOpen: @escaping (_: String?) -> Void,
            onTaskClose: @escaping (_: URLSessionWebSocketTask.CloseCode, _: Data?) -> Void,
            onTaskCompletionWithError: @escaping (_: Swift.Error?) -> Void
        ) {
            self.onTaskOpen = onTaskOpen
            self.onTaskClose = onTaskClose
            self.onTaskCompletionWithError = onTaskCompletionWithError
        }
        
        func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didOpenWithProtocol proto: String?
        ) {
            onTaskOpen(proto)
        }
        
        func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
            reason: Data?
        ) {
            onTaskClose(closeCode, reason)
        }
        
        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            didCompleteWithError error: Swift.Error?
        ) {
            onTaskCompletionWithError(error)
        }
    }
}

// MARK: - Error Handling

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension _AsyncWebSocket {
    public enum Error: Swift.Error {
        case alreadyConnectedOrConnecting
        case notConnected
    }
}
