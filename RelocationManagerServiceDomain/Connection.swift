//
//  Connection.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

// Internal scope because it's just a thin wrapper around `NSXPCConnection`.
// No need to unit test.
class Connection {
    
    let service: NSXPCConnection
    
    init(service: NSXPCConnection) {
        self.service = service
    }
    
    func remoteObjectProxy() -> UsesBoxesAndItems {
        let service = self.service
        return service.remoteObjectProxyWithErrorHandler { error in
            ServiceLocator.errorHandler().handle(error)
            service.invalidate()
        } as! UsesBoxesAndItems
    }
}

extension Connection: ConnectsToClient {
    
    func open() {
        service.resume()
    }
    
    func close() {
        service.invalidate()
    }
    
    func send(event: ClientEvent) {
        let client = remoteObjectProxy()
        DispatchClient(client: client).send(event)
    }
}
