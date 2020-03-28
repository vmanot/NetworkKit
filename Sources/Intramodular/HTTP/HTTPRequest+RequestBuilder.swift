//
// Copyright (c) Vatsal Manot
//

import API
import Merge
import Foundation

extension HTTPRequest {
    public func body<T: Encodable>(_: T.Type) -> RequestBuilderParametrizer<Self, T> {
        parametrize {
            $0.body(try JSONEncoder().encode($1 as T))
        }
    }
}

extension RequestBuilder where Request == HTTPRequest {
    public func response<T: Decodable>(_: T.Type) -> GenericRequestResponseTransformerFunctionality<Self, T> {
        transformResponse {
            try JSONDecoder().decode(T.self, from: $0.data)
        }
    }
}
