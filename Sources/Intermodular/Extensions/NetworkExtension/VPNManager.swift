//
// Copyright (c) Vatsal Manot
//

import NetworkExtension

open class VPNManager: ObservableObject {
    private let base: NEVPNManager
    
    public init(base: NEVPNManager = .shared()) {
        self.base = base
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Self.receiveNotification(_:)),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Self.receiveNotification(_:)),
            name: NSNotification.Name.NEVPNConfigurationChange,
            object: nil
        )
    }
    
    @objc private func receiveNotification(_: NSNotification?) {
        objectWillChange.send()
    }
}

extension VPNManager {
    public var protocolConfiguration: NEVPNProtocol? {
        base.protocolConfiguration
    }
    
    public var status: NEVPNStatus {
        base.connection.status
    }
    
    public func startVPNTunnel() throws {
        try base.connection.startVPNTunnel()
    }
    
    public func stopVPNTunnel() {
        base.connection.stopVPNTunnel()
    }
}
