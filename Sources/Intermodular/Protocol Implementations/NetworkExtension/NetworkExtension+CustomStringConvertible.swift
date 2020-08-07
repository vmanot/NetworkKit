//
// Copyright (c) Vatsal Manot
//

import NetworkExtension
import Swift

extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
            case .invalid:
                return "Invalid"
            case .disconnected:
                return "Disconnected"
            case .connecting:
                return "Connecting"
            case .connected:
                return "Connected"
            case .reasserting:
                return "Reasserting"
            case .disconnecting:
                return "Disconnecting"
            @unknown default:
                return "Unknown"
        }
    }
}
