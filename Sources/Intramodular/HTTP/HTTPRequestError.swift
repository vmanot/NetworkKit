//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum HTTPRequestError: Error {
    case badRequest(Error)
    case urlError(URLError)
    case unknown
    
    public init(_ error: URLError) {
        self = .urlError(error)
    }
}
