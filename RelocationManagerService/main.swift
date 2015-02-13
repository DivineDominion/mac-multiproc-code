//
//  main.swift
//  MultiProcCounter
//
//  Created by Christian Tietze on 22/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa

class TheHelper : NSObject, ManagesBoxesAndItems {
    func provisionBox() {
        
    }
    
    func provisionItem(boxIdentifier: IntegerId) {
        
    }
    
    func removeBox(boxIdentifier: IntegerId) {
        
    }
    
    func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
        
    }
}

class ServiceDelegate : NSObject, NSXPCListenerDelegate {
    func listener(listener: NSXPCListener!, shouldAcceptNewConnection newConnection: NSXPCConnection!) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(`protocol`: ManagesBoxesAndItems.self)
        var exportedObject = TheHelper()
        newConnection.exportedObject = exportedObject
        newConnection.remoteObjectInterface = NSXPCInterface(`protocol`: UsesBoxesAndItems.self)
        
        var valid = true
        
        newConnection.invalidationHandler = {
            //valid = false
            NSLog("invalidated")
        }
        NSLog("accepting connection")
        newConnection.resume()
        
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let listener = newConnection.remoteObjectProxyWithErrorHandler({ error in
                dispatch_async(dispatch_get_main_queue()) {
                    NSLog("error happened")
                }
            }) as UsesBoxesAndItems
            // work with the client
        }
        
        return true
    }
}

let bundleId = NSBundle.mainBundle().bundleIdentifier!
let delegate = ServiceDelegate()
let listener = NSXPCListener(machServiceName: bundleId)
listener.delegate = delegate;
listener.resume()

NSRunLoop.currentRunLoop().run()