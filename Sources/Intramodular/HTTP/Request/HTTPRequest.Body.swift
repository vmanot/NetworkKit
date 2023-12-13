//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

extension HTTPRequest {
    /// Represents the body of an HTTP request.
    public struct Body: Codable, Hashable, Sendable {
        /// The types of content that an `HTTPRequest.Body` can contain.
        public enum Content: Hashable, @unchecked Sendable {
            /// Raw binary data.
            case data(Data)
            
            /// A stream of input data.
            case inputStream(InputStream)
            
            /// Retrieves the `Data` value if the content is `.data`.
            public var dataValue: Data? {
                if case let .data(data) = self {
                    return data
                }
                
                return nil
            }
        }
        
        public let header: [HTTPHeaderField]
        public let content: Content
        
        public var data: Data? {
            content.dataValue
        }
    }
}

// MARK: - Initializers

extension HTTPRequest.Body {
    /// Create a request body with the given data.
    public static func data(_ data: Data) -> Self {
        Self(header: [], content: .data(data))
    }
    
    /// Create a request body the given data and headers.
    public static func data(_ data: Data, headers: [HTTPHeaderField]) -> Self {
        Self(header: headers, content: .data(data))
    }
}

// MARK: - Conformances

extension HTTPRequest.Body.Content: Codable {
    public init(from decoder: Decoder) throws {
        self = .data(try decoder.singleValueContainer().decode(Data.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
            case .data(let data):
                try data.encode(to: encoder)
            case .inputStream(let stream):
                throw EncodingError.invalidValue(stream, EncodingError.Context(codingPath: [], debugDescription: "Cannot encode an InputStream"))
        }
    }
}

extension HTTPRequest.Body: CustomDebugStringConvertible {
    public var debugDescription: String {
        do {
            guard header.isEmpty else {
                return Metatype(Self.self).name
            }
            
            switch content {
                case .data(let data):
                    return try data.toString()
                case .inputStream:
                    return "Input Stream"
            }
        } catch {
            return Metatype(Self.self).name
        }
    }
}

// MARK: - Supplementary

extension HTTPRequest {
    /// Creates a JSON-based query.
    ///
    /// - Parameters:
    ///   - value: An `Encodable` object to encode into a query.
    ///   - dateEncodingStrategy: Optional date encoding strategy.
    ///   - dataEncodingStrategy: Optional data encoding strategy.
    ///   - keyEncodingStrategy: Optional key encoding strategy.
    ///   - nonConformingFloatEncodingStrategy: Optional non-conforming float encoding strategy.
    /// - Throws: An error if encoding fails.
    /// - Returns: An `HTTPRequest` instance with the JSON query set.
    public func jsonQuery<T: Encodable>(
        _ value: T,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) throws -> Self {
        TODO.whole(.fix)
        
        let _encoder = JSONEncoder()
        
        dateEncodingStrategy.map(into: &_encoder.dateEncodingStrategy)
        dataEncodingStrategy.map(into: &_encoder.dataEncodingStrategy)
        keyEncodingStrategy.map(into: &_encoder.keyEncodingStrategy)
        nonConformingFloatEncodingStrategy.map(into: &_encoder.nonConformingFloatEncodingStrategy)
        
        let encoder = _ModularTopLevelEncoder(from: _encoder)
        
        let queryItems = try JSONDecoder()
            .decode([String: AnyCodable].self, from: try encoder.encode(value))
            .map {
                URLQueryItem(
                    name: $0.key,
                    value: try encoder.encode($0.value).toString()
                )
            }
        
        return query(queryItems)
    }
    
    /// Sets a JSON-encoded body.
    ///
    /// - Parameters:
    ///   - value: An `Encodable` object to encode into the body.
    ///   - dateEncodingStrategy: Optional date encoding strategy.
    ///   - dataEncodingStrategy: Optional data encoding strategy.
    ///   - keyEncodingStrategy: Optional key encoding strategy.
    ///   - nonConformingFloatEncodingStrategy: Optional non-conforming float encoding strategy.
    /// - Throws: An error if encoding fails.
    /// - Returns: An `HTTPRequest` instance with the JSON body set.
    public func jsonBody<T: Encodable>(
        _ value: T,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) throws -> Self {
        return try _jsonBody(
            value,
            dateEncodingStrategy: dateEncodingStrategy,
            dataEncodingStrategy: dataEncodingStrategy,
            keyEncodingStrategy: keyEncodingStrategy,
            nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy
        )
    }
    
    /// Sets a JSON-encoded body using a dictionary.
    ///
    /// - Parameter value: A `[String: Any?]` dictionary to encode into the body.
    /// - Throws: An error if serialization fails.
    /// - Returns: An `HTTPRequest` instance with the JSON body set.
    public func jsonBody(
        _ value: [String: Any?]
    ) throws -> Self {
        body(
            try JSONSerialization.data(
                withJSONObject: value.compactMapValues({ $0 }),
                options: [.fragmentsAllowed, .sortedKeys]
            )
        )
    }
    
    /// Sets a JSON-encoded body using generic type T.
    ///
    /// - Parameters:
    ///   - value: An object to encode into the body.
    ///   - dateEncodingStrategy: Optional date encoding strategy.
    ///   - dataEncodingStrategy: Optional data encoding strategy.
    ///   - keyEncodingStrategy: Optional key encoding strategy.
    ///   - nonConformingFloatEncodingStrategy: Optional non-conforming float encoding strategy.
    /// - Throws: An error if encoding fails.
    /// - Returns: An `HTTPRequest` instance with the JSON body set.
    public func jsonBody<T>(
        _ value: T,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) throws -> Self {
        if value is Void {
            return self // FIXME?
        } else if let value = value as? Encodable {
            return try _opaque_jsonBody(
                value,
                dateEncodingStrategy: dateEncodingStrategy,
                dataEncodingStrategy: dataEncodingStrategy,
                keyEncodingStrategy: keyEncodingStrategy,
                nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy
            )
        } else if _isValueNil(value) {
            return self
        } else {
            assertionFailure("Failed to encode value of type: \(type(of: value)), \(value)")
            
            return self
        }
    }
    
    public func jsonBody(
        _ value: (any Encodable)?,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) throws -> Self {
        if let value {
            return try _opaque_jsonBody(
                value,
                dateEncodingStrategy: dateEncodingStrategy,
                dataEncodingStrategy: dataEncodingStrategy,
                keyEncodingStrategy: keyEncodingStrategy,
                nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy
            )
        } else {
            return self
        }
    }
    
    private func _jsonBody<T: Encodable>(
        _ value: T,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) throws -> Self {
        let _encoder = JSONEncoder()
        
        dateEncodingStrategy.map(into: &_encoder.dateEncodingStrategy)
        dataEncodingStrategy.map(into: &_encoder.dataEncodingStrategy)
        keyEncodingStrategy.map(into: &_encoder.keyEncodingStrategy)
        nonConformingFloatEncodingStrategy.map(into: &_encoder.nonConformingFloatEncodingStrategy)
        
        let encoder = _ModularTopLevelEncoder(from: _encoder)
        
        return body(try encoder.encode(value)).header(.contentType(.json))
    }
    
    private func _opaque_jsonBody(
        _ value: (any Encodable)?,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) throws -> Self {
        func _makeJSONBody<T: Encodable>(_ x: T) throws -> Self {
            try self._jsonBody(
                x,
                dateEncodingStrategy: dateEncodingStrategy,
                dataEncodingStrategy: dataEncodingStrategy,
                keyEncodingStrategy: keyEncodingStrategy,
                nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy
            )
        }
        
        if let value {
            return try _openExistential(value, do: _makeJSONBody)
        } else {
            return self
        }
    }
}
