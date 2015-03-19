//
//  PrepareConnection.swift
//  RelocationManager
//
//  Created by Christian Tietze on 19/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

class PrepareConnection: NSObject, NSXPCListenerDelegate {
    func listener(listener: NSXPCListener!, shouldAcceptNewConnection newConnection: NSXPCConnection!) -> Bool {
        
        // TODO endpoint is retained; make it so that it contains the connection
        let endpoint = Endpoint()
        
        newConnection.exportedInterface = NSXPCInterface(`protocol`: ManagesBoxesAndItems.self)
        newConnection.exportedObject = endpoint
        
        newConnection.remoteObjectInterface = NSXPCInterface(`protocol`: UsesBoxesAndItems.self)
        
        // TODO handle invalidation inside connection controller
        newConnection.invalidationHandler = {
            NSLog("invalidated")
        }
        NSLog("accepting connection")
        newConnection.resume()
        
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            // TODO create listener as part of a new connection
            let listener = newConnection.remoteObjectProxyWithErrorHandler { error in
                ServiceLocator.errorHandler().handle(error)
            } as UsesBoxesAndItems
            
            let connection = Connection(client: listener)
            let connectionController = ConnectionController(connection: connection)
        }
        
        return true
    }
}
