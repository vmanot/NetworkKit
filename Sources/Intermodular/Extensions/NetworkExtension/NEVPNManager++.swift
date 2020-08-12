//
// Copyright (c) Vatsal Manot
//

import NetworkExtension
import Swift

extension NEVPNManager {
    public func disconnectIfNecessary() -> AnyFuture<Void, Error> {
        connection.stop()
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
