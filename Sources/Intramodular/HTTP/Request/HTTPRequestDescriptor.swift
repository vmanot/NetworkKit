//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol HTTPRequestDescriptor {
    func populate(_: HTTPRequest) throws -> HTTPRequest
}
