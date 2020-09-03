//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol HTTPRequestBody {
    var header: [HTTPHeaderField] { get }
    
    func content() throws -> HTTPRequestBodyContent
}

// MARK: - Implementation -

extension HTTPRequestBody {
    public var header: [HTTPHeaderField] {
        return []
    }
}

// MARK: - Concrete Implementations -

extension Data: HTTPRequestBody {
    public func content() throws -> HTTPRequestBodyContent {
        return .data(self)
    }
}

// MARK: - Helpers -

extension HTTPRequest {
    public func jsonBody<T: Encodable>(
        _ value: T,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) throws -> Self {
        let encoder = JSONEncoder()
        
        dateEncodingStrategy.map(into: &encoder.dateEncodingStrategy)
        dataEncodingStrategy.map(into: &encoder.dataEncodingStrategy)
        keyEncodingStrategy.map(into: &encoder.keyEncodingStrategy)
        nonConformingFloatEncodingStrategy.map(into: &encoder.nonConformingFloatEncodingStrategy)
        
        return body(try encoder.encode(value))
    }
    
    public func jsonBody(_ value: [String: Any?]) throws -> Self {
        body(
            try JSONSerialization.data(
                withJSONObject: value.compactMapValues({ $0 }),
                options: [.fragmentsAllowed, .sortedKeys]
            )
        )
    }
}
