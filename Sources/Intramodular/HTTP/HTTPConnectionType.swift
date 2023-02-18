//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPConnectionType: String, Hashable, Sendable {
    case close = "close"
    case keepAlive = "keep-alive"
}
