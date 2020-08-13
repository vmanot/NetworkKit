//
// Copyright (c) Vatsal Manot
//

import NetworkExtension
import Swift

extension NEVPNStatus {
    public var isTransient: Bool {
        switch self {
            case .invalid:
                return false
            case .disconnected:
                return false
            case .connecting:
                return true
            case .connected:
                return false
            case .reasserting:
                return true
            case .disconnecting:
                return true
            @unknown default:
                return false
        }
    }
}
