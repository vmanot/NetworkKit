//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct HTTPResponse {
    public let data: Data
    public let urlResponse: HTTPURLResponse
    
    public var code: HTTPResponseStatusCode {
        .init(rawValue: urlResponse.statusCode)
    }
    
    public var header: [HTTPHeaderField] {
        urlResponse
            .allHeaderFields
            .map({ HTTPHeaderField(key: $0, value: $1) })
    }
}

extension HTTPResponse {
    public func validate() throws {
        if code == .error {
            throw HTTPRequest.Error.badRequest(self)
        }
    }
}

extension HTTPResponse {
    public func decodeJSON<T: Decodable>(
        _ type: T.Type,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy? = nil,
        nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy? = nil,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? = nil
    ) throws -> T {
        let decoder = JSONDecoder()
        
        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        }
        
        if let dataDecodingStrategy = dataDecodingStrategy {
            decoder.dataDecodingStrategy = dataDecodingStrategy
        }
        
        if let nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy {
            decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        }
        
        if let keyDecodingStrategy = keyDecodingStrategy {
            decoder.keyDecodingStrategy = keyDecodingStrategy
        }
        
        return try decoder.decode(type, from: data)
    }
}

// MARK: - Protocol Conformances -

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

// MARK: - Helpers -

extension HTTPResponse {
    public init(_ response: CachedURLResponse) throws {
        self.init(data: response.data, urlResponse: try cast(response.response, to: HTTPURLResponse.self))
    }
}

extension CachedURLResponse {
    public convenience init(_ response: HTTPResponse) {
        self.init(response: response.urlResponse, data: response.data)
    }
}
