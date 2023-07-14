//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPMediaType: Codable, Hashable, RawRepresentable, Sendable {
    case json
    case xml
    case eventStream
    case octetStream
    case anything
    case custom(String)
    
    public var rawValue: String {
        switch self {
            case .json:
                return "application/json"
            case .xml:
                return "application/xml"
            case .eventStream:
                return "text/event-stream"
            case .octetStream:
                return "application/octet-stream"
                
            case .anything:
                return "*/*"
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
            case Self.eventStream.rawValue:
                self = .eventStream
            case Self.octetStream.rawValue:
                self = .octetStream
            case Self.anything.rawValue:
                self = .anything
            default:
                self = .custom(rawValue)
        }
    }
}
