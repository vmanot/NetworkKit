//
// Copyright (c) Vatsal Manot
//

import Swift

extension HTTPRequest {
    public struct Multipart {
        
    }
}

// MARK: - Auxiliary

extension HTTPRequest {
    public func body(
        _ content: HTTPRequest.Multipart.Content
    ) -> Self {
        self
            .deleteHeader(.contentType)
            .body(
                Body(
                    header: content.headers.map {
                        .init(
                            key: $0.name.rawValue,
                            value: $0.valueWithAttributes
                        )
                    },
                    content: .data(content.body)
                )
            )
    }
    
    public func body(
        _ type: HTTPRequest.Multipart.Content.Subtype,
        _ data: [HTTPRequest.Multipart.Part]
    ) -> Self {
        self.body(HTTPRequest.Multipart.Content(type: type, parts: data))
    }
}
