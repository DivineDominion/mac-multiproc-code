//
//  main.swift
//  MultiProcCounter
//
//  Created by Christian Tietze on 22/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa


class ServiceDelegate : NSObject, NSXPCListenerDelegate {
    func listener(listener: NSXPCListener!, shouldAcceptNewConnection newConnection: NSXPCConnection!) -> Bool {
        
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
            let listener = newConnection.remoteObjectProxyWithErrorHandler({ error in
                dispatch_async(dispatch_get_main_queue()) {
                    NSLog("error happened")
                }
            }) as UsesBoxesAndItems
            
            let connection = Connection(endpoint: endpoint, client: listener)
            let connectionController = ConnectionController(connection: connection)
        }
        
        return true
    }
}

let bundleId = NSBundle.mainBundle().bundleIdentifier!
let delegate = ServiceDelegate()
let listener = NSXPCListener(machServiceName: bundleId)
listener.delegate = delegate
listener.resume()

NSRunLoop.currentRunLoop().run()
