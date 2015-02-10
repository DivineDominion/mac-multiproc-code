//
//  main.swift
//  MultiProcCounter
//
//  Created by Christian Tietze on 22/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa

class TheHelper : NSObject, ProvidesCounts {
    func currentCount(reply: ((UInt) -> Void)!) {
        reply(4455)
    }
}

class ServiceDelegate : NSObject, NSXPCListenerDelegate {
    func listener(listener: NSXPCListener!, shouldAcceptNewConnection newConnection: NSXPCConnection!) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(`protocol`: ProvidesCounts.self)
        var exportedObject = TheHelper()
        newConnection.exportedObject = exportedObject
        newConnection.remoteObjectInterface = NSXPCInterface(`protocol`: Listener.self)
        
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
            }) as Listener
            
            for (var i = 0; i < 10; i++) {
                NSThread.sleepForTimeInterval(3)
                if (!valid) {
                    NSLog("aborting")
                    break
                }
                
                listener.updateTicker(i)
            }
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
