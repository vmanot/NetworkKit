//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol HTTPResponseDecodable {
    init(from response: HTTPResponse) throws
}
