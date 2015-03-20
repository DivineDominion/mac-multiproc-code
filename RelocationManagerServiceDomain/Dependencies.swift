//
//  Dependencies.swift
//  RelocationManager
//
//  Created by Christian Tietze on 19/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

class Dependencies: NSObject {
    
    var bundle: NSBundle {
        return NSBundle.mainBundle()
    }
    
    var sharedBundleDirectory: NSURL {
        return NSURL()
    }
    
    lazy var persistentStack: PersistentStack = {
        
        let storeURL = self.sharedBundleDirectory.URLByAppendingPathComponent(kDefaultStoreName);
        let modelURL = self.bundle.URLForResource(kDefaultModelName, withExtension: "momd")
        let errorHandler = ServiceLocator.errorHandler()
        
        return PersistentStack(storeURL: storeURL, modelURL: modelURL!, errorHandler: errorHandler)
    }()
    
    lazy var listener: NSXPCListener = {
        
        let bundleId = self.bundle.bundleIdentifier!
        return NSXPCListener(machServiceName: bundleId)
    }()
    
    /// Returns `Dependencies` object (self) upon success, or `nil` upon failure.
    func setUp() -> Dependencies? {
        
        if let moc = persistentStack.managedObjectContext {
            ServiceLocator.sharedInstance.setManagedObjectContext(moc)
            
            setUpListener()
            
            return self
        }
        
        return nil
    }
    
    private func setUpListener() {
        
        listener.delegate = self
        listener.resume()
    }
}

extension Dependencies: NSXPCListenerDelegate {
    
    func listener(listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        
        // TODO set up invalidation handler
        if let controller = PrepareConnection().prepare(newConnection).build() {
            controller.openConnection()
            
            // TODO retain controller
            
            return true
        }
        
        return false
    }
}
