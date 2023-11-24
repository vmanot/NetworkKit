//
// Copyright (c) Vatsal Manot
//

import Combine
import CorePersistence
import FoundationX
import Swallow

/// A modern replacement for the `(Data, HTTPResponse)` tuple.
public struct HTTPResponse: Codable, Hashable, Sendable {
    public let data: Data
    @NSKeyedArchived
    var cocoaURLResponse: HTTPURLResponse
    
    /// The response’s HTTP status code.
    public var statusCode: HTTPResponseStatusCode {
        .init(rawValue: cocoaURLResponse.statusCode)
    }
    
    /// All HTTP header fields of the response.
    public var headerFields: [HTTPHeaderField] {
        cocoaURLResponse
            .allHeaderFields
            .map({ HTTPHeaderField(key: $0, value: $1) })
    }
    
    /// Throw a Swift error if the response code indicates an error.
    public func validate() throws {
        guard statusCode != .error else {
            throw HTTPRequest.Error.badRequest(self)
        }
    }
}

extension HTTPResponse {
    /// Decodes an instance of the indicated type.
    public func decode<T, Decoder: TopLevelDecoder>(
        _ type: T.Type,
        using decoder: Decoder
    ) throws -> T where Decoder.Input == Data {
        if let type = type as? HTTPResponseDecodable.Type {
            return try type.init(from: self) as! T
        } else {
            return try decoder.attemptToDecode(type, from: data)
        }
    }
    
    /// Decodes an instance of the indicated type.
    public func decode<T>(
        _ type: T.Type,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy? = nil,
        nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy? = nil,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? = nil
    ) throws -> T {
        if let type = type as? HTTPResponseDecodable.Type {
            return try type.init(from: self) as! T
        }
        
        let _decoder = JSONDecoder()
        
        if let dateDecodingStrategy = dateDecodingStrategy {
            _decoder.dateDecodingStrategy = dateDecodingStrategy
        }
        
        if let dataDecodingStrategy = dataDecodingStrategy {
            _decoder.dataDecodingStrategy = dataDecodingStrategy
        }
        
        if let nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy {
            _decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        }
        
        if let keyDecodingStrategy = keyDecodingStrategy {
            _decoder.keyDecodingStrategy = keyDecodingStrategy
        }
        
        let decoder = _ModularTopLevelDecoder(from: _decoder)
        
        return try decoder.attemptToDecode(type, from: data)
    }
}

extension HTTPResponse {
    /// Attempts to decode an instance of the indicated type.
    public func attemptToDecode<T>(
        _ type: T.Type
    ) throws -> T  {
        if let type = type as? HTTPResponseDecodable.Type {
            return try type.init(from: self) as! T
        } else if headerFields.contains(.contentType(.json)) {
            return try _ModularTopLevelDecoder(from: JSONDecoder()).attemptToDecode(type, from: data)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: []))
        }
    }
}

// MARK: - Conformances

extension HTTPResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else {
            return String(data: self.data, encoding: .utf8) ?? "<<error>>"
        }
        
        return prettyPrintedString
    }
}

// MARK: - Supplementary

extension HTTPResponse {
    public init(
        _ response: CachedURLResponse
    ) throws {
        self.init(data: response.data, cocoaURLResponse: try cast(response.response, to: HTTPURLResponse.self))
    }
}

extension CachedURLResponse {
    public convenience init(
        _ response: HTTPResponse
    ) {
        self.init(response: response.cocoaURLResponse, data: response.data)
    }
}
