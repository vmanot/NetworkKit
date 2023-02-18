//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension HTTPHeaderField {
    /// A structure representing a RFC 5988 link.
    public struct Link: Equatable, Hashable {
        public let uri: String
        public let parameters: [String: String]
        
        public var url: URL? {
            URL(string: uri)
        }
        
        public init(uri: String, parameters: [String: String]? = nil) {
            self.uri = uri
            self.parameters = parameters ?? [:]
        }
        
        public var relationType: String? {
            parameters["rel"]
        }
        
        public var reverseRelationType: String? {
            parameters["rev"]
        }
        
        public var type: String? {
            parameters["type"]
        }
        
        public init(header: String) throws {
            let components = header.components(separatedBy: "; ")
            
            let parameters = components.dropFirst()
                .map {
                    $0.splitInHalf(separator: "=")
                }
                .map { parameter in
                    [parameter.0: parameter.1.trim(prefix: "\"", suffix: "\"") as String]
                }
            
            
            self.uri = try components.first.unwrap().trim(prefix: "<", suffix: ">")
            self.parameters = parameters.reduce([:], { $0.merging($1, uniquingKeysWith: { lhs, _ in lhs }) })
        }
    }
}

extension HTTPHeaderField.Link {
    public var html: String {
        let components = parameters.map { key, value in
            "\(key)=\"\(value)\""
        } + ["href=\"\(uri)\""]
        
        let elements = components.joined(separator: " ")
        
        return "<link \(elements) />"
    }
    
    /// Encode the link into a header
    public var header: String {
        let components = ["<\(uri)>"] + parameters.map { key, value in
            "\(key)=\"\(value)\""
        }
        
        return components.joined(separator: "; ")
    }
}

// MARK: - API

extension HTTPResponse {
    public var links: [HTTPHeaderField.Link] {
        do {
            guard let linkHeader = self.headerFields[.custom("Link")] else {
                return []
            }
            
            return try linkHeader
                .components(separatedBy: ",")
                .map(HTTPHeaderField.Link.init(header:))
                .map { link in
                    var uri = link.uri
                    
                    if let baseURL = self.cocoaURLResponse.url, let relativeURI = URL(string: uri, relativeTo: baseURL)?.absoluteString {
                        uri = relativeURI
                    }
                    
                    return .init(uri: uri, parameters: link.parameters)
                }
        } catch {
            return []
        }
    }
}
