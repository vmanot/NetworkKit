//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum HTTPRequestBodyContent: HTTPRequestBody {
    case data(Data)
    case inputStream(InputStream)
    
    public func content() -> HTTPRequestBodyContent {
        self
    }
}
