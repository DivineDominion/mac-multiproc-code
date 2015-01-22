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
        newConnection.resume()
        return true
    }
}

NSLog("argh")
let bundleId = NSBundle.mainBundle().bundleIdentifier!
let delegate = ServiceDelegate()
let listener = NSXPCListener(machServiceName: bundleId)
listener.delegate = delegate;
listener.resume()
NSLog("argh2")
NSRunLoop.currentRunLoop().run()
