//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swift

extension HTTPRequest.Multipart {
    /// Defines a message in which one or more different sets of data are combined according to the MIME standard.
    /// - SeeAlso: Defined in [RFC 2046, Section 5.1](https://tools.ietf.org/html/rfc2046#section-5.1)
    public struct Content {
        static let CRLF = "\r\n"
        static let CRLFData = HTTPRequest.Multipart.Content.CRLF.data(using: .utf8)!
        
        /// A string that is optionally inserted before the first boundary delimiter. Can be used as an explanatory note for
        /// recipients who read the message with pre-MIME software, since such notes will be ignored by MIME-compliant software.
        public var preamble: String? = nil
        
        /// Message headers that apply to this body part.
        public var headers: [HTTPRequest.Multipart.HeaderField] = []
        
        private let type: Subtype
        private let boundary = HTTPRequest.Multipart.Content.Boundary()
        private var entities: [HTTPRequestMultipartContentEntity]
        
        /// Creates and initializes a Multipart body with the given subtype.
        /// - Parameter type: The multipart subtype
        /// - Parameter parts: Array of body subparts to encapsulate
        public init(
            type: Subtype,
            parts: [HTTPRequestMultipartContentEntity] = []
        ) {
            self.type = type
            self.entities = parts
            
            setValue("\(type.rawValue); boundary=\(self.boundary.stringValue)", for: .contentType)
        }
        
        /// Adds a subpart to the end of the body.
        /// - Parameter newElement: Part or nested Multipart to append to the body
        public mutating func append(_ newElement: HTTPRequestMultipartContentEntity) {
            entities.append(newElement)
        }
    }
}

// MARK: - Protocol Implementations -

extension HTTPRequest.Multipart.Content: CustomStringConvertible {
    public var description: String {
        var result = self.headers.string() + HTTPRequest.Multipart.Content.CRLF
        
        if let preamble = self.preamble {
            result += String()
                + preamble
                + HTTPRequest.Multipart.Content.CRLF
                + HTTPRequest.Multipart.Content.CRLF
        }
        
        if entities.count > 0 {
            for entity in entities {
                result += String()
                    + boundary.delimiter
                    + HTTPRequest.Multipart.Content.CRLF
                    + entity.description
                    + HTTPRequest.Multipart.Content.CRLF
            }
        } else {
            result += String()
                + boundary.delimiter
                + HTTPRequest.Multipart.Content.CRLF
                + HTTPRequest.Multipart.Content.CRLF
        }
        
        result += self.boundary.distinguishedDelimiter
        
        return result
    }
}

extension HTTPRequest.Multipart.Content: HTTPRequestMultipartContentEntity {
    /// Complete message body, including boundaries and any nested multipart containers.
    public var body: Data {
        var data = Data()
        
        if let preamble = preamble?.data(using: .utf8) {
            data.append(preamble + HTTPRequest.Multipart.Content.CRLFData)
            data.append(HTTPRequest.Multipart.Content.CRLFData)
        }
        
        if entities.count > 0 {
            for entity in entities {
                data.append(boundary.delimiterData + HTTPRequest.Multipart.Content.CRLFData)
                
                if let headerData = entity.headers.data() {
                    data.append(headerData)
                }
                
                data.append(HTTPRequest.Multipart.Content.CRLFData)
                data.append(entity.body + HTTPRequest.Multipart.Content.CRLFData)
            }
        } else {
            data.append(boundary.delimiterData)
            data.append(HTTPRequest.Multipart.Content.CRLFData)
            data.append(HTTPRequest.Multipart.Content.CRLFData)
        }
        
        data.append(boundary.distinguishedDelimiterData)
        
        return data
    }
}

extension HTTPRequest.Multipart.Content: HTTPRequestBody {
    public var requiredHeaderComponents: [HTTPHeaderField] {
        headers.map({ .custom(key: $0.name.rawValue, value: $0.valueWithAttributes) })
    }
    
    public func buildEntity() throws -> HTTPRequestBodyEntity {
        .data(body)
    }
}

extension HTTPRequest.Multipart.Content: Sequence {
    public typealias Iterator = IndexingIterator<[HTTPRequestMultipartContentEntity]>
    
    public func makeIterator() -> Iterator {
        entities.makeIterator()
    }
}
