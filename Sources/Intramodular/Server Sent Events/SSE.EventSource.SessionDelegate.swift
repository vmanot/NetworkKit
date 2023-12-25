//
// Copyright (c) Vatsal Manot
//

import Foundation

extension SSE.EventSource {
    final class SessionDelegate: NSObject, URLSessionDataDelegate {
        enum Event {
            case dataTaskDidComplete(Result<Void, Error>)
            case dataTaskDidReceiveResponse(URLResponse, (URLSession.ResponseDisposition) -> Void)
            case dataTaskDidReceiveData(Data)
        }
        
        let onEvent: (Event) -> Void
        
        init(onEvent: @escaping (Event) -> Void) {
            self.onEvent = onEvent
        }
        
        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            didCompleteWithError error: Error?
        ) {
            if let error {
                onEvent(.dataTaskDidComplete(.failure(error)))
            } else {
                onEvent(.dataTaskDidComplete(.success(())))
            }
        }
        
        func urlSession(
            _ session: URLSession,
            dataTask: URLSessionDataTask,
            didReceive response: URLResponse,
            completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
        ) {
            onEvent(.dataTaskDidReceiveResponse(response, completionHandler))
        }
        
        func urlSession(
            _ session: URLSession,
            dataTask: URLSessionDataTask,
            didReceive data: Data
        ) {
            onEvent(.dataTaskDidReceiveData(data))
        }
    }
}
