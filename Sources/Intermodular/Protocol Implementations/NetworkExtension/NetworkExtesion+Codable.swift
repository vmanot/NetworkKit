//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import NetworkExtension
import Swift

extension NEVPNStatus: @retroactive Encodable, @retroactive Decodable {

}

#endif
