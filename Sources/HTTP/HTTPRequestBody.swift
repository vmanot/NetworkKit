//
// Copyright (c) Vatsal Manot
//

import Data
import Foundation
import Swift

public protocol HTTPRequestBody {
    func buildEntity() throws -> HTTPRequestBodyEntity
}

// MARK: - Concrete Implementations -

extension Data: HTTPRequestBody {
    public func buildEntity() throws -> HTTPRequestBodyEntity {
        return .data(self)
    }
}

extension JSON: HTTPRequestBody {
    public func buildEntity() throws -> HTTPRequestBodyEntity {
        .data(try toJSONData())
    }
}
