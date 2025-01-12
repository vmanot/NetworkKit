//
// Copyright (c) Vatsal Manot
//

import Swift
import UniformTypeIdentifiers

public enum HTTPMediaType: Codable, Hashable, RawRepresentable, Sendable {
    // Text types
    case plainText
    case html
    case css
    case javascript
    case csv
    case markdown
    
    // Image types
    case jpeg
    case png
    case gif
    case svg
    case webp
    
    // Application types
    case json
    case xml
    case pdf
    case zip
    case form
    case m4a
    case mp4
    case mpeg
    case eventStream
    case octetStream
    case webm
    case wav
    
    case anything
    case custom(String)
    
    public var rawValue: String {
        switch self {
                // Text types
            case .plainText:
                return "text/plain"
            case .html:
                return "text/html"
            case .css:
                return "text/css"
            case .javascript:
                return "text/javascript"
            case .csv:
                return "text/csv"
            case .markdown:
                return "text/markdown"
                
                // Image types
            case .jpeg:
                return "image/jpeg"
            case .png:
                return "image/png"
            case .gif:
                return "image/gif"
            case .svg:
                return "image/svg+xml"
            case .webp:
                return "image/webp"
                
                // Application types
            case .json:
                return "application/json"
            case .xml:
                return "application/xml"
            case .pdf:
                return "application/pdf"
            case .zip:
                return "application/zip"
            case .form:
                return "application/x-www-form-urlencoded"
            case .m4a:
                return "audio/m4a"
            case .mp4:
                return "audio/mp4"
            case .mpeg:
                return "audio/mpeg"
            case .eventStream:
                return "text/event-stream"
            case .octetStream:
                return "application/octet-stream"
            case .webm:
                return "audio/webm"
            case .wav:
                return "audio/wav"
                
            case .anything:
                return "*/*"
            case .custom(let value):
                return value
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
            case Self.plainText.rawValue:
                self = .plainText
            case Self.html.rawValue:
                self = .html
            case Self.css.rawValue:
                self = .css
            case Self.javascript.rawValue:
                self = .javascript
            case Self.csv.rawValue:
                self = .csv
            case Self.markdown.rawValue:
                self = .markdown
            case Self.jpeg.rawValue:
                self = .jpeg
            case Self.png.rawValue:
                self = .png
            case Self.gif.rawValue:
                self = .gif
            case Self.svg.rawValue:
                self = .svg
            case Self.webp.rawValue:
                self = .webp
            case Self.json.rawValue:
                self = .json
            case Self.xml.rawValue:
                self = .xml
            case Self.pdf.rawValue:
                self = .pdf
            case Self.zip.rawValue:
                self = .zip
            case Self.form.rawValue:
                self = .form
            case Self.mpeg.rawValue:
                self = .mpeg
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
    
    public init?(_swiftType type: Any.Type) {
        switch type {
            case Data.self:
                self = .octetStream
            case String.self:
                self = .plainText
            default:
                return nil
        }
    }
}

extension HTTPMediaType {
    public init?(fileURL: URL) {
        guard let mimeType: String = fileURL._actuallyStandardizedFileURL._detectPreferredMIMEType() else {
            runtimeIssue("Failed to determine preferred MIME type for file: \(fileURL)")
            
            return nil
        }
        
        self = Self(rawValue: mimeType)
    }
}
