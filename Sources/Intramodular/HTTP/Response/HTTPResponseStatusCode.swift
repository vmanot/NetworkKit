//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A type representing an HTTP response status code.
public struct HTTPResponseStatusCode {
    public enum CodeType {
        case information
        case success
        case redirect
        case clientError
        case serverError
        case unknown
    }
    
    public let rawValue: Int
    
    public var codeType: CodeType {
        switch rawValue {
            case 100...199:
                return .information
            case 200...299:
                return .success
            case 300...399:
                return .redirect
            case 400...499:
                return .clientError
            case 500...599:
                return .serverError
            default:
                return .unknown
        }
    }
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension HTTPResponseStatusCode {
    public init(_ response: HTTPURLResponse) {
        self.init(rawValue: response.statusCode)
    }
}

extension HTTPResponseStatusCode {
    public enum Comparison {
        case success
        case error
    }
    
    public static func == (lhs: Self, rhs: Comparison) -> Bool {
        switch rhs {
            case .success:
                return lhs.codeType == .success
            case .error:
                return lhs.codeType == .clientError || lhs.codeType == .serverError
        }
    }
}
