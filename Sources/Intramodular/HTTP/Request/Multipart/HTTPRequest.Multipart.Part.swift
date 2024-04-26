//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension HTTPRequest.Multipart {
    /// A message part that can be added to Multipart containers.
    public struct Part: HTTPRequestMultipartContentEntity {
        public enum _Charset: String {
            case utf8 = "utf-8"
            case ISO_8859_1 = "ISO-8859-1"
        }
        
        public var body: Data
        public var headers: [HTTPRequest.Multipart.HeaderField] = []
        
        public init(
            body: Data,
            contentType: String? = nil
        ) {
            self.body = body
            
            if let contentType = contentType {
                setValue(contentType, for: .contentType)
            }
        }
        
        public init(
            body: String,
            contentType: String? = nil
        ) {
            self.init(
                body: body.data(using: .utf8) ?? Data(),
                contentType: contentType
            )
            
            self.setAttribute(
                attribute: "charset",
                value: _Charset.utf8.rawValue,
                for: .contentType
            )
        }
    }
}

extension HTTPRequest.Multipart.Part {
    /// A "multipart/form-data" part containing a form field and its corresponding value, which can be added to
    /// Multipart containers.
    /// - Parameter name: Field name from the form.
    /// - Parameter value: Value from the form field.
    public static func formData(
        name: String,
        value: String
    ) -> Self {
        var part = Self(body: value)
        
        part.setValue("form-data", for: .contentDisposition)
        part.setAttribute(attribute: "name", value: name, for: .contentDisposition)
        
        return part
    }
    
    /// A "multipart/form-data" part containing file data, which can be added to Multipart containers.
    /// - Parameter name: Field name from the form.
    /// - Parameter fileData: Complete contents of the file.
    /// - Parameter fileName: Original local file name of the file.
    /// - Parameter contentType: MIME Content-Type specifying the nature of the data.
    public static func formData(
        name: String,
        fileData: Data,
        fileName: String?,
        contentType: String?
    ) -> Self {
        var part = Self(body: fileData)
        
        part.setValue("form-data", for: .contentDisposition)
        part.setAttribute(attribute: "name", value: name, for: .contentDisposition)
        
        if let fileName = fileName {
            part.setAttribute(attribute: "filename", value: fileName, for: .contentDisposition)
        }
        
        if let contentType = contentType {
            part.setValue(contentType, for: .contentType)
        }
        
        return part
    }
        
    public static func file(
        named field: String,
        data: Data,
        filename: String,
        contentType: HTTPMediaType
    ) -> Self {
        self.formData(
            name: field,
            fileData: data,
            fileName: filename,
            contentType: contentType.rawValue
        )
    }
    
    public static func text(
        named field: String,
        value: String
    ) -> Self {
        self.formData(
            name: field,
            fileData: value.data(using: .utf8)!,
            fileName: nil,
            contentType: "text/plain"
        )
    }
}

extension HTTPRequest.Multipart.Part: CustomStringConvertible {
    public var description: String {
        var result = headers.string() + HTTPRequest.Multipart.Content.CRLF
        
        if let string = String(data: body, encoding: .utf8) {
            result.append(string)
        } else {
            result.append("(\(body.count) bytes)")
        }
        
        return result
    }
}

// MARK: - Deprecated

extension HTTPRequest.Multipart.Part {
    public static func file(
        _ data: Data,
        contentType: HTTPMediaType,
        fileName: String,
        forField field: String
    ) -> Self {
        self.formData(
            name: field,
            fileData: data,
            fileName: fileName,
            contentType: contentType.rawValue
        )
    }
}
