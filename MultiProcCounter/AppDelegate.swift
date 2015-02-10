//
//  AppDelegate.swift
//  MultiProcCounter
//
//  Created by Christian Tietze on 19/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import ServiceManagement

func createXPCConnection(loginItemName: NSString, error: NSErrorPointer) -> NSXPCConnection? {
    let mainBundleURL = NSBundle.mainBundle().bundleURL
    let loginItemDirURL = mainBundleURL.URLByAppendingPathComponent("Contents/Library/LoginItems", isDirectory: true)
    let loginItemURL = loginItemDirURL.URLByAppendingPathComponent(loginItemName)
    
    return createXPCConnection(loginItemURL, error)
}

/// Constant for 1 as a true Boolean
let TRUE: Boolean = 1 as Boolean
/// Constant for 0 as a true Boolean
let FALSE: Boolean = 0 as Boolean

func createXPCConnection(loginItemURL: NSURL, error: NSErrorPointer) -> NSXPCConnection? {
    let loginItemBundle = NSBundle(URL: loginItemURL)
    
    if loginItemBundle == nil {
        if error != nil {
            error.memory = NSError(domain:NSPOSIXErrorDomain, code:Int(EINVAL), userInfo: [
                NSLocalizedFailureReasonErrorKey: "failed to load bundle",
                NSURLErrorKey: loginItemURL
            ])
        }
        return nil
    }
    
    // Lookup the bundle identifier for the login item.
    // LaunchServices implicitly registers a mach service for the login
    // item whose name is the name as the login item's bundle identifier.
    if loginItemBundle!.bundleIdentifier? == nil {
        if error != nil {
            error.memory = NSError(domain:NSPOSIXErrorDomain, code:Int(EINVAL), userInfo:[
                NSLocalizedFailureReasonErrorKey: "bundle has no identifier",
                NSURLErrorKey: loginItemURL
            ])
        }
        return nil
    }
    let loginItemBundleId = loginItemBundle!.bundleIdentifier!
    
    // The login item's file name must match its bundle Id.
    let loginItemBaseName = loginItemURL.lastPathComponent!.stringByDeletingPathExtension
    if loginItemBundleId != loginItemBaseName {
        if error != nil {
            let message = NSString(format: "expected bundle identifier \"%@\" for login item \"%@\", got \"%@\"", loginItemBaseName, loginItemURL, loginItemBundleId)
            error.memory = NSError(domain:NSPOSIXErrorDomain, code:Int(EINVAL), userInfo:[
                NSLocalizedFailureReasonErrorKey: "bundle identifier does not match file name",
                NSLocalizedDescriptionKey: message,
                NSURLErrorKey: loginItemURL
            ])
        }
        return nil
    }
    
    // Enable the login item.
    // This will start it running if it wasn't already running.
    if SMLoginItemSetEnabled(loginItemBundleId as CFString, TRUE) != TRUE {
        if error != nil {
            error.memory = NSError(domain:NSPOSIXErrorDomain, code:Int(EINVAL), userInfo:[
                NSLocalizedFailureReasonErrorKey: "SMLoginItemSetEnabled() failed"
            ])
        }
        return nil
    }
    
    return NSXPCConnection(machServiceName: loginItemBundleId, options: NSXPCConnectionOptions(0))
}

@NSApplicationMain
class AppDelegate: NSObject, NSWindowDelegate, NSApplicationDelegate, Listener {

    @IBOutlet weak var window: NSWindow!
    var connection: NSXPCConnection?
    var helper: ProvidesCounts?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        window.delegate = self
        
        var error: NSError?
        connect(&error)
        
        if (self.connection == nil) {
            NSLog("conn failed %@", error!.description)
            return
        }
        
        connection!.remoteObjectInterface = NSXPCInterface(`protocol`: ProvidesCounts.self)
        connection!.exportedInterface = NSXPCInterface(`protocol`: Listener.self)
        connection!.exportedObject = self
        connection!.resume()
        
        // Get a proxy DecisionAgent object for the connection.
        helper = connection!.remoteObjectProxyWithErrorHandler() { (err) -> Void in
            // This block is run when an error occurs communicating with
            // the launch item service.  This will not be invoked on the
            // main queue, so re-schedule a block on the main queue to
            // update the U.I.
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("Failed to query oracle: %@\n\n", err.description)
            }
        } as? ProvidesCounts
        
        if helper == nil {
            NSLog("No helper")
        }
        
        helper!.currentCount() { (result) -> Void in
            NSLog("The result is: \(result)")
        }
    }
    
    func connect(error: NSErrorPointer) {
        connection = createXPCConnection("FRMDA3XRGC.de.christiantietze.multiproc.Helper.app", error)
    }
    
    func windowWillClose(notification: NSNotification) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func updateTicker(tick: Int) {
        NSLog("Tick #\(tick)")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        let object = connection!.remoteObjectProxyWithErrorHandler { (error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("Failed to query oracle: %@\n\n", error.description)
            }
        } as ProvidesCounts
        object.currentCount() { (result) -> Void in
            NSLog("The result is: \(result)")
        }
        //helper = nil
        connection?.invalidate()
    }

    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        let object = connection!.remoteObjectProxyWithErrorHandler { (error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("Failed to query oracle: %@\n\n", error.description)
            }
        } as ProvidesCounts
        object.currentCount() { (result) -> Void in
            NSLog("The result is: \(result)")
        }
        return .TerminateNow
    }

}

