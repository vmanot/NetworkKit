//
// Copyright (c) Vatsal Manot
//

import Combine
import FoundationX
import Merge
import Swallow

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public final class _AsyncWebSocket {
    public typealias Message = URLSessionWebSocketTask.Message
    
    public enum State: Hashable {
        case notConnected
        case connecting
        case connected
        case disconnected(AnyError?)
    }
    
    private let queue = ThrowingTaskQueue()
    private let timeout: DispatchTimeInterval
    
    @Published private(set) var state: State = .notConnected
    
    private var messagesStream: AsyncThrowingStream<Message, Swift.Error>?
    private var messagesContinuation: AsyncThrowingStream<Message, Swift.Error>.Continuation?
    
    private let urlRequest: URLRequest
    private let urlSession: URLSession
    private var socketTask: URLSessionWebSocketTask?
    private var socketTaskDelegate: SocketTaskDelegate?
    
    public init(
        request: URLRequest,
        session: URLSession = .shared,
        timeout: DispatchTimeInterval = .seconds(30)
    ) {
        self.urlRequest = request
        self.urlSession = session
        self.timeout = timeout
    }
    
    deinit {
        _disconnect()
    }
    
    @discardableResult
    public func connect() async throws -> AsyncThrowingStream<Message, Swift.Error> {
        try await queue.perform {
            try await _connect()
        }
    }
    
    private func _connect() async throws -> AsyncThrowingStream<Message, Swift.Error> {
        guard case .notConnected = state else {
            throw Error.alreadyConnectedOrConnecting
        }
        
        state = .connecting
        
        let (stream, continuation) = AsyncThrowingStream<Message, Swift.Error>.makeStream()

        self.messagesStream = stream
        self.messagesContinuation = continuation
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self._runSocketTask()
            }
            
            group.addTask {
                try await Task.sleep(self.timeout)
                throw Error.connectionTimeout
            }
            
            do {
                try await group.next()
                group.cancelAll()
            } catch {
                group.cancelAll()
                state = .disconnected(AnyError(erasing: error))
                throw error
            }
        }
        
        return stream
    }
    
    public func send(_ string: String) async throws {
        try await send(.string(string))
    }
    
    public func send(_ data: Data) async throws {
        try await send(.data(data))
    }
    
    public func send<Encoder: TopLevelEncoder>(
        _ value: Encodable,
        encoder: Encoder
    ) async throws where Encoder.Output == Data {
        let data = try encoder.encode(value)
        
        try await send(.data(data))
    }
    
    public func disconnect() async {
        do {
            try await queue.waitForAll()
        } catch {
            runtimeIssue(error)
        }
        
        try! await queue.perform {
            self._disconnect()
        }
    }
    
    private func _disconnect() {
        guard case .connected = state else {
            return
        }
        
        messagesContinuation?.finish()
        socketTask?.cancel(with: .normalClosure, reason: nil)
        socketTask = nil
        socketTaskDelegate = nil
        state = .disconnected(nil)
    }
    
    public var messages: AsyncThrowingStream<Message, Swift.Error> {
        get async throws {
            guard let stream = messagesStream else {
                return try await _connect()
            }
            
            return stream
        }
    }
    
    public func queue<T>(
        @_implicitSelfCapture operation: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        try await queue.perform {
            switch await state {
                case .notConnected:
                    try await connect()
                case .connecting:
                    try await withTaskTimeout(timeout) {
                        await withCheckedContinuation { continuation in
                            Task {
                                _ = await self.$state.values.dropFirst().first {
                                    $0 == .connected
                                }
                                
                                continuation.resume()
                            }
                        }
                    }
                case .connected:
                    break
                case .disconnected:
                    throw Error.notConnected
            }
            
            return try await operation()
        }
    }
    
    private func _runSocketTask() async throws {
        let delegate = SocketTaskDelegate { [weak self] _ in
            guard let self = self else {
                return
            }
            
            Task {
                self.handleConnected()
            }
        } onTaskClose: { [weak self] _, _ in
            guard let self = self else {
                return
            }
            
            Task {
                self.handleDisconnection(withError: nil)
            }
        } onTaskCompletionWithError: { [weak self] error in
            guard let self = self else {
                return
            }
            
            Task {
                self.handleDisconnection(withError: error)
            }
        }
        
        socketTaskDelegate = delegate
        socketTask = urlSession.webSocketTask(with: urlRequest)
        socketTask?.delegate = delegate
        socketTask?.resume()
        
        try await withCheckedThrowingContinuation { continuation in
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                
                for await newState in self.$state.values {
                    if case .connected = newState {
                        continuation.resume()
                        return
                    } else if case .disconnected(let error) = newState {
                        continuation.resume(throwing: error ?? Error.notConnected)
                        return
                    }
                }
            }
        }
    }
    
    private func handleConnected() {
        state = .connected
        receive()
    }
    
    private func send(
        _ message: URLSessionWebSocketTask.Message
    ) async throws {
        guard case .connected = state else {
            throw Error.notConnected
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Swift.Error>) in
            socketTask?.send(message) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func receive() {
        guard let task = socketTask, case .connected = state else { return }
        
        task.receive { [weak self] result in
            guard let self = self else { return }
            Task {
                self.handleReceive(result)
            }
        }
    }
    
    private func handleReceive(
        _ result: Result<Message, Swift.Error>
    ) {
        switch result {
            case .success(let message):
                messagesContinuation?.yield(message)
                receive()
            case .failure(let error):
                handleDisconnection(withError: error)
        }
    }
    
    private func handleDisconnection(
        withError error: (any Swift.Error)?
    ) {
        state = .disconnected(AnyError(erasing: error))
        messagesContinuation?.finish(throwing: error)
        socketTask = nil
        socketTaskDelegate = nil
    }
}

extension _AsyncWebSocket {
    private class SocketTaskDelegate: NSObject, URLSessionWebSocketDelegate {
        private let onTaskOpen: (_ protocol: String?) -> Void
        private let onTaskClose: (_ code: URLSessionWebSocketTask.CloseCode, _ reason: Data?) -> Void
        private let onTaskCompletionWithError: (_ error: Swift.Error?) -> Void
        
        init(
            onTaskOpen: @escaping @Sendable (_: String?) -> Void,
            onTaskClose: @escaping @Sendable (_: URLSessionWebSocketTask.CloseCode, _: Data?) -> Void,
            onTaskCompletionWithError: @escaping @Sendable (_: Swift.Error?) -> Void
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

// MARK: - Initializers

extension _AsyncWebSocket {
    public convenience init(
        url: URL,
        session: URLSession = .shared,
        timeout: DispatchTimeInterval = .seconds(30)
    ) {
        self.init(request: URLRequest(url: url), session: session, timeout: timeout)
    }
}

// MARK: - Error Handling

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension _AsyncWebSocket {
    public enum Error: Swift.Error {
        case alreadyConnectedOrConnecting
        case notConnected
        case connectionTimeout
        case unexpectedMessageType
        case taskCancelled
    }
}

extension _AsyncWebSocket.Message {
    public func data() throws -> Data {
        switch self {
            case let .data(data):
                return data
            case let .string(string):
                guard let data = string.data(using: .utf8) else {
                    throw DecodingError.dataCorrupted(.init(codingPath: []))
                }

                return data
            @unknown default:
                preconditionFailure("Unknown URLSessionWebSocketTask.Message case")
        }
    }
    
    public func decode<Type: Decodable>(
        _ type: Type.Type
    ) throws -> Type {
        switch self {
            case .data:
                TODO.unimplemented
            case .string:
                return try JSONDecoder().decode(type, from: data())
            @unknown default:
                return try JSONDecoder().decode(type, from: data())
        }
    }
}
