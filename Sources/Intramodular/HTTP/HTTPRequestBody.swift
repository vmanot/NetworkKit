//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol HTTPRequestBody {
    var requiredHeaderComponents: [HTTPHeaderComponent] { get }
    
    func buildEntity() throws -> HTTPRequestBodyEntity
}

// MARK: - Implementation -

extension HTTPRequestBody {
    public var requiredHeaderComponents: [HTTPHeaderComponent] {
        return []
    }
}

// MARK: - Concrete Implementations -

extension Data: HTTPRequestBody {
    public func buildEntity() throws -> HTTPRequestBodyEntity {
        return .data(self)
    }
}
