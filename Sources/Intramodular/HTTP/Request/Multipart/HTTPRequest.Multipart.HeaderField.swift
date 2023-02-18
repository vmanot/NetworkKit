//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension HTTPRequest.Multipart {
    /// A message header for use with multipart entities and subparts.
    public struct HeaderField {
        /// Header name such as "Content-Type".
        public let name: HTTPHeaderField.Key
        
        /// Header value, not including attributes.
        public var value: String
        
        /// Header attributes like "name" or "filename".
        public var attributes: [String: String]
        
        /// Complete header value, including attributes.
        public var valueWithAttributes: String {
            get {
                var strings = [value]
                
                for attribute in attributes {
                    if let attributeValue = attribute.value.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) {
                        strings.append("\(attribute.key)=\"\(attributeValue)\"")
                    }
                }
                
                return strings.joined(separator: "; ")
            }
        }
        
        public init(
            name: HTTPHeaderField.Key,
            value: String,
            attributes: [String:String] = [:]
        ) {
            self.name = name
            self.value = value
            self.attributes = attributes
        }
        
        /// Return complete header including name, value and attributes. Does not include line break.
        public func string() -> String {
            return "\(name.rawValue): \(valueWithAttributes)"
        }
    }
}

// MARK: - Helpers

extension Array where Iterator.Element == HTTPRequest.Multipart.HeaderField {
    subscript(key: HTTPHeaderField.Key) -> HTTPRequest.Multipart.HeaderField? {
        get {
            first(where: { $0.name == key })
        } set {
            if let index = firstIndex(where: { $0.name == key }) {
                remove(at: index)
                
                if let newValue = newValue {
                    insert(newValue, at: index)
                }
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
    
    public mutating func remove(_ key: HTTPHeaderField.Key) {
        if let index = firstIndex(where: { $0.name == key }) {
            remove(at: index)
        }
    }
    
    /// Return all headers as a single string, each terminated with a line break.
    public func string() -> String {
        map({ $0.string() + HTTPRequest.Multipart.Content.CRLF }).joined()
    }
    
    /// Return all headers, each terminated with a line break.
    public func data(using encoding: String.Encoding = .utf8) -> Data? {
        string().data(using: encoding)
    }
}
