//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol HTTPRequestDescriptor: Codable {
    func populate(_: HTTPRequest) throws -> HTTPRequest
}
