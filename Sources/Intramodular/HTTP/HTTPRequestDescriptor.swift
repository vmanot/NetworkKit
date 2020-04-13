//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol HTTPRequestDescriptor: Encodable {
    func populate(_: HTTPRequest) throws -> HTTPRequest
}
