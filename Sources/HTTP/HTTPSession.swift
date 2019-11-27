//
// Copyright (c) Vatsal Manot
//

import CombineX
import Foundation
import Swift

public protocol HTTPSession {
    func createTask(with request: HTTPRequest) -> Future<HTTPRequestResponse, HTTPRequestError>
    
    func getTasks() -> Future<[HTTPSessionTask], Never>
}

// MARK: - Implementation -

extension URLSession: HTTPSession {
    public func createTask(with request: HTTPRequest) -> Future<HTTPRequestResponse, HTTPRequestError> {
        do {
            return try dataTaskPublisher(for: request)
                .map { .init(data: $0.data, urlResponse: $0.response) }
                .mapError { .urlError($0) }
                .toFuture()
        } catch {
            return .just(.failure(.badRequest(error)))
        }
    }
    
    public func getTasks() -> Future<[HTTPSessionTask], Never> {
        .init { fulfill in
            self.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
                let allTasks = []
                    + dataTasks as [URLSessionTask]
                    + uploadTasks as [URLSessionTask]
                    + downloadTasks as [URLSessionTask]
                
                fulfill(.success(allTasks.map { $0 }))
            }
        }
    }
}

