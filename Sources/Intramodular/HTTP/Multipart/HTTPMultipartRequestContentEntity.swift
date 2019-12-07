//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol HTTPMultipartRequestContentEntity: CustomStringConvertible {
    var body: Data { get }
    var headers: [HTTPMultipartRequestHeader] { get set }
}

extension HTTPMultipartRequestContentEntity {
    
    /// Sets an attribute for a header field, like the "name" attribute for the Content-Disposition header.
    /// If the specified header is not defined for this entity, the attribute is ignored.
    /// If a value was previously set for the given attribute, that value is replaced with the given value.
    public mutating func setAttribute(attribute: String, value: String?, forHeaderField headerName: String) {
        if let value = value {
            self.headers[headerName]?.attributes[attribute] = value
        } else {
            self.headers[headerName]?.attributes.removeValue(forKey: attribute)
        }
    }
    
    /// Sets a value for a header field. If a value was previously set for the given header, that value is replaced with
    /// the given value.
    public mutating func setValue(_ value: String?, forHeaderField headerName: String) {
        if let value = value {
            if self.headers[headerName] != nil {
                self.headers[headerName]?.value = value
            } else {
                self.headers.append(HTTPMultipartRequestHeader(name: headerName, value: value))
            }
        } else {
            self.headers.remove(headerName)
        }
    }
}
