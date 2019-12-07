//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

struct HTTPContentBoundary {
    let stringValue: String
    
    var delimiter: String {
        return "--" + stringValue
    }
    
    var distinguishedDelimiter: String {
        delimiter + "--"
    }
    
    var delimiterData: Data {
        return delimiter.data(using: .utf8)!
    }
    
    var distinguishedDelimiterData: Data {
        distinguishedDelimiter.data(using: .utf8)!
    }
    
    init() {
        stringValue = (UUID().uuidString + UUID().uuidString)
            .replacingOccurrences(of: "-", with: "")
    }
}
