//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension HTTPRequest.Multipart.Content {
    public struct Boundary {
        public let stringValue: String
        
        public var delimiter: String {
            "--" + stringValue
        }
        
        public var distinguishedDelimiter: String {
            delimiter + "--"
        }
        
        public var delimiterData: Data {
            delimiter.data(using: .utf8)!
        }
        
        public var distinguishedDelimiterData: Data {
            distinguishedDelimiter.data(using: .utf8)!
        }
        
        public init() {
            stringValue = (UUID().uuidString + UUID().uuidString)
                .replacingOccurrences(of: "-", with: "")
        }
    }
}
