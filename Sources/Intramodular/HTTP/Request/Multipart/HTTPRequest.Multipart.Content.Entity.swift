//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

protocol HTTPRequestMultipartContentEntity: CustomStringConvertible {
    var headers: [HTTPRequest.Multipart.HeaderField] { get set }
    var body: Data { get }
}

// MARK: - Extensions

extension HTTPRequestMultipartContentEntity {
    /// Sets an attribute for a header field, like the "name" attribute for the Content-Disposition header.
    /// If the specified header is not defined for this entity, the attribute is ignored.
    /// If a value was previously set for the given attribute, that value is replaced with the given value.
    mutating func setAttribute(
        attribute: String,
        value: String?,
        for key: HTTPHeaderField.Key
    ) {
        if let value = value {
            headers[key]?.attributes[attribute] = value
        } else {
            headers[key]?.attributes.removeValue(forKey: attribute)
        }
    }
    
    /// Sets a value for a header field. If a value was previously set for the given header, that value is replaced with the given value.
    mutating func setValue(
        _ value: String?,
        for key: HTTPHeaderField.Key
    ) {
        if let value = value {
            if headers[key] != nil {
                headers[key]?.value = value
            } else {
                headers.append(.init(name: key, value: value))
            }
        } else {
            headers.remove(key)
        }
    }
}
