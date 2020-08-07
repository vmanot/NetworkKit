//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public struct HTTPResponse {
    public let data: Data
    public let urlResponse: HTTPURLResponse
    
    public var code: HTTPResponseStatusCode {
        return .init(rawValue: urlResponse.statusCode)
    }
    
    public var headers: [HTTPHeaderField] {
        urlResponse
            .allHeaderFields
            .map({ HTTPHeaderField(key: $0, value: $1) })
    }
}

extension HTTPResponse {
    public func validate() throws {
        if code == .error {
            throw HTTPRequestError.badRequest(self)
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
