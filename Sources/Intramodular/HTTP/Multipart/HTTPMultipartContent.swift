//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swift

/// Defines a message in which one or more different sets of data are combined according to the MIME standard.
/// - SeeAlso: Defined in [RFC 2046, Section 5.1](https://tools.ietf.org/html/rfc2046#section-5.1)
public struct HTTPMultipartContent {
    static let CRLF = "\r\n"
    static let CRLFData = HTTPMultipartContent.CRLF.data(using: .utf8)!
    
    /// A string that is optionally inserted before the first boundary delimiter. Can be used as an explanatory note for
    /// recipients who read the message with pre-MIME software, since such notes will be ignored by MIME-compliant software.
    public var preamble: String? = nil
    
    /// Message headers that apply to this body part.
    public var headers: [HTTPRequest.Multipart.HeaderField] = []
    
    private let type: Subtype
    private let boundary = HTTPMultipartContent.Boundary()
    private var entities: [HTTPMultipartContentEntity]
    
    /// Creates and initializes a Multipart body with the given subtype.
    /// - Parameter type: The multipart subtype
    /// - Parameter parts: Array of body subparts to encapsulate
    public init(
        type: Subtype,
        parts: [HTTPMultipartContentEntity] = []
    ) {
        self.type = type
        self.entities = parts
        
        setValue("\(type.rawValue); boundary=\(self.boundary.stringValue)", for: .contentType)
    }
    
    /// Adds a subpart to the end of the body.
    /// - Parameter newElement: Part or nested Multipart to append to the body
    public mutating func append(_ newElement: HTTPMultipartContentEntity) {
        entities.append(newElement)
    }
}

// MARK: - Protocol Implementations -

extension HTTPMultipartContent: CustomStringConvertible {
    public var description: String {
        var descriptionString = self.headers.string() + HTTPMultipartContent.CRLF
        
        if let preamble = self.preamble {
            descriptionString += String()
                + preamble
                + HTTPMultipartContent.CRLF
                + HTTPMultipartContent.CRLF
        }
        
        if entities.count > 0 {
            for entity in entities {
                descriptionString += String()
                    + boundary.delimiter
                    + HTTPMultipartContent.CRLF
                    + entity.description
                    + HTTPMultipartContent.CRLF
            }
        } else {
            descriptionString += String()
                + boundary.delimiter
                + HTTPMultipartContent.CRLF
                + HTTPMultipartContent.CRLF
        }
        
        descriptionString += self.boundary.distinguishedDelimiter
        
        return descriptionString
    }
}

extension HTTPMultipartContent: HTTPMultipartContentEntity {
    /// Complete message body, including boundaries and any nested multipart containers.
    public var body: Data {
        var data = Data()
        
        if let preamble = preamble?.data(using: .utf8) {
            data.append(preamble + HTTPMultipartContent.CRLFData)
            data.append(HTTPMultipartContent.CRLFData)
        }
        
        if entities.count > 0 {
            for entity in entities {
                data.append(boundary.delimiterData + HTTPMultipartContent.CRLFData)
                
                if let headerData = entity.headers.data() {
                    data.append(headerData)
                }
                
                data.append(HTTPMultipartContent.CRLFData)
                data.append(entity.body + HTTPMultipartContent.CRLFData)
            }
        } else {
            data.append(boundary.delimiterData)
            data.append(HTTPMultipartContent.CRLFData)
            data.append(HTTPMultipartContent.CRLFData)
        }
        
        data.append(boundary.distinguishedDelimiterData)
        
        return data
    }
}

extension HTTPMultipartContent: HTTPRequestBody {
    public var requiredHeaderComponents: [HTTPHeaderField] {
        headers.map({ .custom(key: $0.name.rawValue, value: $0.valueWithAttributes) })
    }
    
    public func buildEntity() throws -> HTTPRequestBodyEntity {
        .data(body)
    }
}

extension HTTPMultipartContent: Sequence {
    public typealias Iterator = IndexingIterator<[HTTPMultipartContentEntity]>
    
    public func makeIterator() -> Iterator {
        entities.makeIterator()
    }
}
