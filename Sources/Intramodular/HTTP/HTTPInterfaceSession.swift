//
// Copyright (c) Vatsal Manot
//

import API
import Merge
import Swift

open class HTTPInterfaceSession<Interface: HTTPInterface>: ProgramInterfaceSession {
    public let interface: Interface
    public let session: HTTPSession
    
    public init(interface: Interface) {
        self.interface = interface
        self.session = .init()
    }
}

