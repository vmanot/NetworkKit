//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import Merge
import NetworkExtension
import Swift

extension NEVPNConnection {
    private enum _Error: Error {
        case badStatus(NEVPNStatus)
        case unknownStatus(NEVPNStatus)
    }
    
    public func start() -> AnySingleOutputPublisher<Void, Error> {
        guard status != .connected else {
            return .just(())
        }
        
        let publisher = NotificationCenter.default.publisher(for: .NEVPNStatusDidChange, object: self).flatMap { _ -> AnyPublisher<Void, _Error> in
            switch self.status {
                case .invalid:
                    return .failure(.badStatus(self.status))
                case .disconnected:
                    return .empty()
                case .connecting:
                    return .empty()
                case .connected:
                    return .just(())
                case .reasserting:
                    return .empty()
                case .disconnecting:
                    return .empty()
                @unknown default:
                    return .failure(.unknownStatus(self.status))
            }
        }
        .prefix(1)
        .eraseError()
        ._unsafe_eraseToAnySingleOutputPublisher()
        
        do {
            try startVPNTunnel()
        } catch {
            return .failure(error)
        }
        
        if status == .connected {
            return .just(())
        } else if status == .invalid {
            return .failure(_Error.badStatus(status))
        }
        
        return publisher
    }
    
    public func stop() -> AnySingleOutputPublisher<Void, Error> {
        guard status != .disconnected else {
            return .just(())
        }
        
        stopVPNTunnel()
        
        if status == .disconnected {
            return .just(())
        } else if status == .invalid {
            return .failure(_Error.badStatus(status))
        }
        
        return NotificationCenter.default.publisher(for: .NEVPNStatusDidChange, object: self).flatMap { _ -> AnyPublisher<Void, _Error> in
            switch self.status {
                case .invalid:
                    return .failure(.badStatus(self.status))
                case .disconnected:
                    return .just(())
                case .connecting:
                    return .empty()
                case .connected:
                    return .empty()
                case .reasserting:
                    return .empty()
                case .disconnecting:
                    return .empty()
                @unknown default:
                    return .failure(.unknownStatus(self.status))
            }
        }
        .prefix(1)
        .eraseError()
        ._unsafe_eraseToAnySingleOutputPublisher()
    }
}

#endif
