//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol HTTPRequestBody {
    var requiredHeaderComponents: [HTTPHeaderField] { get }
    
    func buildEntity() throws -> HTTPRequestBodyEntity
}

// MARK: - Implementation -

extension HTTPRequestBody {
    public var requiredHeaderComponents: [HTTPHeaderField] {
        return []
    }
}

// MARK: - Concrete Implementations -

extension Data: HTTPRequestBody {
    public func buildEntity() throws -> HTTPRequestBodyEntity {
        return .data(self)
    }
}
