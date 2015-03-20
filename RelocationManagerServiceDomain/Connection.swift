//
//  Connection.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

extension DispatchClient {
    class func create(connection: Connection) -> DispatchClient {
        return DispatchClient(client: connection.remoteObjectProxy())
    }
}

// Internal scope because it's just a thin wrapper around `NSXPCConnection`.
// No need to unit test.
class Connection: ConnectsToClient {
    
    let service: NSXPCConnection
    
    init(service: NSXPCConnection) {
        self.service = service
    }
    
    func remoteObjectProxy() -> UsesBoxesAndItems {
        let service = self.service
        return service.remoteObjectProxyWithErrorHandler { error in
            ServiceLocator.errorHandler().handle(error)
            service.invalidate()
        } as UsesBoxesAndItems
    }
    
    func open() {
        service.resume()
    }
    
    func close() {
        service.invalidate()
    }
    
    func send(event: ClientEvent) {
        DispatchClient.create(self).send(event)
    }
}
