//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol HTTPRequestPopulator {
    func populate(_: HTTPRequest) throws -> HTTPRequest
}
