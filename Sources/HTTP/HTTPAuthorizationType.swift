//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPAuthorizationType: String {
    case basic = "Basic"
    case bearer = "Bearer"
    case digest = "Digest"
    case hoba = "HOBA"
    case mutual = "Mutual"
    case aws = "AWS4-HMAC-SHA256"
}
