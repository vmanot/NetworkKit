//
// Copyright (c) Vatsal Manot
//

import NetworkExtension
import Swift

extension NEVPNManager {
    public func disconnectIfNecessary(
        timeout timeoutInterval: RunLoop.SchedulerTimeType.Stride? = nil
    ) -> AnyFuture<Void, Error> {
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
            ._unsafe_eraseToAnyFuture()
        }
        
        return connection.stop()
    }
    
    public final func loadFromPreferences() -> Future<Void, Error> {
        Future { attemptToFulfill in
            self.loadFromPreferences(completionHandler: { error in
                if let error = error {
                    attemptToFulfill(.failure(error))
                } else {
                    attemptToFulfill(.success(()))
                }
            })
        }
    }
    
    public final func removeFromPreferences() -> Future<Void, Error> {
        Future { attemptToFulfill in
            self.removeFromPreferences(completionHandler: { error in
                if let error = error {
                    attemptToFulfill(.failure(error))
                } else {
                    attemptToFulfill(.success(()))
                }
            })
        }
    }
    
    public final func saveToPreferences() -> Future<Void, Error> {
        Future { attemptToFulfill in
            self.removeFromPreferences(completionHandler: { error in
                if let error = error {
                    attemptToFulfill(.failure(error))
                } else {
                    attemptToFulfill(.success(()))
                }
            })
        }
    }
    
}
