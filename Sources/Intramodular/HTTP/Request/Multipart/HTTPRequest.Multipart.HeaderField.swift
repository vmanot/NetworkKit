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
        public var attributes: [Attribute.Name: Attribute]
        
        public init(
            name: HTTPHeaderField.Key,
            value: String,
            attributes: [Attribute.Name: Attribute] = [:]
        ) {
            self.name = name
            self.value = value
            self.attributes = attributes
        }
    }
}

extension HTTPRequest.Multipart.HeaderField {
    public var headerValueIncludingAttributes: String {
        get {
            var strings = [value]
            
            for (name, attribute) in attributes {
                do {
                    let attributeValue = try attribute.formattedValueForHeaderString()
                    
                    strings.append("\(name.rawValue)=\"\(attributeValue)\"")
                } catch {
                    runtimeIssue(error)
                }
            }
            
            return strings.joined(separator: "; ")
        }
    }
    
    /// Return complete header including name, value and attributes. Does not include line break.
    public func headerKeyValueStringIncludingAttributes() -> String {
        "\(name.rawValue): \(headerValueIncludingAttributes)"
    }
}

// MARK: - Initializers

extension HTTPRequest.Multipart.HeaderField {
    public init(
        name: HTTPHeaderField.Key,
        value: String,
        attributes: [String: String]
    ) {
        self.init(
            name: name,
            value: value,
            attributes: attributes.mapKeys({ Attribute.Name(rawValue: $0) }).mapValues({ Attribute(value: $0) })
        )
    }
}

// MARK: - Auxiliary

extension HTTPRequest.Multipart.HeaderField {
    /// A type that represents an attribute value along with some options.
    public struct Attribute: Codable, Hashable, Sendable {
        public struct Name: Codable, Hashable, RawRepresentable, Sendable {
            public let rawValue: String
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
        
        public enum Option: Codable, Hashable, Sendable {
            case percentEncoded(allowedCharacters: CharacterSet)
        }
        
        public let value: String
        public var options: Set<Option>
        
        fileprivate func formattedValueForHeaderString() throws -> String {
            if let allowedCharactersForPercentEncoding: CharacterSet = options.first(byUnwrapping: /Option.percentEncoded(allowedCharacters:)) {
                return try value.addingPercentEncoding(withAllowedCharacters: allowedCharactersForPercentEncoding).unwrap()
            } else {
                return value
            }
        }
        
        public init(value: String, options: Set<Option> = [Option.percentEncoded(allowedCharacters: .urlQueryAllowed)]) {
            self.value = value
            self.options = options
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
    public func headerString() -> String {
        map {
            $0.headerKeyValueStringIncludingAttributes() + HTTPRequest.Multipart.Content.CRLF
        }
        .joined()
    }
    
    /// Return all headers, each terminated with a line break.
    public func headerData(
        using encoding: String.Encoding = .utf8
    ) -> Data? {
        headerString().data(using: encoding)
    }
}
