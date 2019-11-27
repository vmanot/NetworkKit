//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum HTTPRequestBodyEntity: HTTPRequestBody {
    case data(Data)
    case inputStream(InputStream)
    
    public func buildEntity() -> HTTPRequestBodyEntity {
        self
    }
}
