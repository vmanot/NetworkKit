//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPMediaType: Codable, Hashable, RawRepresentable {
    case json
    case xml
    
    case custom(String)
    
    public var rawValue: String {
        switch self {
            case .json:
                return "application/json"
            case .xml:
                return "application/xml"
            case .custom(let value):
                return value
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
            case Self.json.rawValue:
                self = .json
            case Self.xml.rawValue:
                self = .xml
            default:
                self = .custom(rawValue)
        }
    }
}
