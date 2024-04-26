//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow

extension HTTPRequest.Multipart {
    public protocol ContentConvertible {
        func __conversion() throws -> HTTPRequest.Multipart.Content
    }
    
    /// Defines a message in which one or more different sets of data are combined according to the MIME standard.
    /// - SeeAlso: Defined in [RFC 2046, Section 5.1](https://tools.ietf.org/html/rfc2046#section-5.1)
    public struct Content: Initiable {
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
        private init(
            type: Subtype,
            parts: [HTTPRequestMultipartContentEntity] = []
        ) {
            self.type = type
            self.entities = parts
            
            setValue("\(type.rawValue); boundary=\(self.boundary.stringValue)", for: .contentType)
        }
        
        /// Creates and initializes a Multipart body with the given subtype.
        /// - Parameter type: The multipart subtype
        /// - Parameter parts: Array of body subparts to encapsulate
        public init(
            type: Subtype,
            parts: [HTTPRequest.Multipart.Part] = []
        ) {
            self.init(type: type, parts: parts.map({ $0 as HTTPRequestMultipartContentEntity }))
        }
        
        public init(
            _ parts: [HTTPRequest.Multipart.Part]
        ) {
            self.init(type: .formData, parts: parts)
        }
        
        public init() {
            self.init([HTTPRequest.Multipart.Part]())
        }
    }
}

extension HTTPRequest.Multipart.Content {
    public mutating func append(_ element: HTTPRequest.Multipart.Part) {
        _append(element)
    }

    private mutating func _append(_ element: any HTTPRequestMultipartContentEntity) {
        entities.append(element)
    }
    
    public enum _PartContent {
        
    }
}

// MARK: - Conformances

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
