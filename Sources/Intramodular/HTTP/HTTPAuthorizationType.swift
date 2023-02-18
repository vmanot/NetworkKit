//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPAuthorizationType: Hashable, Sendable {
    case basic
    case bearer
    case digest
    case hoba
    case mutual
    case aws
    case custom(String)
    
    public var rawValue: String {
        switch self {
            case .basic:
                return "Basic"
            case .bearer:
                return "Bearer"
            case .digest:
                return "Digest"
            case .hoba:
                return "HOBA"
            case .mutual:
                return "Mutual"
            case .aws:
                return "AWS4-HMAC-SHA256"
            case .custom(let value):
                return value
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
            case Self.basic.rawValue:
                self = .basic
            case Self.bearer.rawValue:
                self = .bearer
            case Self.digest.rawValue:
                self = .digest
            case Self.hoba.rawValue:
                self = .hoba
            case Self.mutual.rawValue:
                self = .mutual
            case Self.aws.rawValue:
                self = .aws
            default:
                self = .custom(rawValue)
        }
    }
}
