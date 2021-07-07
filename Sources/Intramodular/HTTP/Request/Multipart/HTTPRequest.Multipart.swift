//
// Copyright (c) Vatsal Manot
//

import Swift

extension HTTPRequest {
    public struct Multipart {
        
    }
}

// MARK: - Auxiliary Implementation -

extension HTTPRequest {
    public func body(_ content: HTTPRequest.Multipart.Content) -> Self {
        body(
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
}
