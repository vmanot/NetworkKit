//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import Merge
import NetworkExtension
import Swift

extension NEVPNManager {
    // Start the process of disconnecting the VPN.
    public func disconnectIfNecessary(
        timeout timeoutInterval: RunLoop.SchedulerTimeType.Stride? = nil
    ) -> AnySingleOutputPublisher<Void, Error> {
        enum DisconnectTimeoutError: Error {
            case unknown
        }
        
        if let timeoutInterval = timeoutInterval {
            return connection.stop().timeout(
                timeoutInterval,
                scheduler: RunLoop.main,
                options: nil,
                customError: {
                    DisconnectTimeoutError.unknown
                }
            )
            ._unsafe_eraseToAnySingleOutputPublisher()
        }
        
        return connection.stop()
    }
    
    /// Load the VPN configuration from the Network Extension preferences.
    public final func loadFromPreferences() -> Future<Void, Error> {
        Future { attemptToFulfill in
            self.loadFromPreferences { error in
                if let error = error {
                    attemptToFulfill(.failure(error))
                } else {
                    attemptToFulfill(.success(()))
                }
            }
        }
    }
    
    /// Remove the VPN configuration from the Network Extension preferences.
    public final func removeFromPreferences() -> Future<Void, Error> {
        Future { attemptToFulfill in
            self.removeFromPreferences { error in
                if let error = error {
                    attemptToFulfill(.failure(error))
                } else {
                    attemptToFulfill(.success(()))
                }
            }
        }
    }
    
    public final func saveToPreferences() -> Future<Void, Error> {
        Future { attemptToFulfill in
            self.saveToPreferences { error in
                if let error = error {
                    attemptToFulfill(.failure(error))
                } else {
                    attemptToFulfill(.success(()))
                }
            }
        }
    }
}

#endif
