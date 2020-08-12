//
// Copyright (c) Vatsal Manot
//

import Merge
import NetworkExtension
import Swift

extension NEVPNConnection {
    private enum StopVPNTunnelError: Error {
        case badStatus(NEVPNStatus)
    }
    
    public func stop() -> AnyFuture<Void, Error> {
        guard status != .disconnected else {
            return .just(())
        }
        
        stopVPNTunnel()
        
        if status == .disconnected {
            return .just(())
        } else if status == .invalid {
            return .failure(StopVPNTunnelError.badStatus(status))
        }
        
        return publisher(for: \.status).flatMap { status -> AnyPublisher<Void, StopVPNTunnelError> in
            switch status {
                case .invalid:
                    return AnyPublisher.failure(StopVPNTunnelError.badStatus(status))
                case .disconnected:
                    return AnyPublisher.just(())
                case .connecting:
                    return AnyPublisher.empty()
                case .connected:
                    return AnyPublisher.empty()
                case .reasserting:
                    return AnyPublisher.empty()
                case .disconnecting:
                    return AnyPublisher.empty()
                @unknown default:
                    return AnyPublisher.failure(StopVPNTunnelError.badStatus(status))
            }
        }
        .prefix(1)
        ._unsafe_eraseToAnyFuture()
    }
}
