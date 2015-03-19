//
//  Dependencies.swift
//  RelocationManager
//
//  Created by Christian Tietze on 19/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

class Dependencies {
    let connectionService = PrepareConnection()
    
    init() { }
    
    func setUp() -> Dependencies? {
        setUpCoreData()
        
        if let moc = persistentStack.managedObjectContext {
            ServiceLocator.sharedInstance.setManagedObjectContext(moc)
            
            setUpListener()
            
            return self
        }
        
        return nil
    }
    
    var bundle: NSBundle {
        return NSBundle.mainBundle()
    }
    
    private func setUpListener() {
        let bundleId = bundle.bundleIdentifier!
        let listener = NSXPCListener(machServiceName: bundleId)
        listener.delegate = connectionService
        listener.resume()
    }
    
    var sharedBundleDirectory: NSURL {
        return NSURL()
    }
    
    var persistentStack: PersistentStack!
    
    private func setUpCoreData() {
        let storeURL = sharedBundleDirectory.URLByAppendingPathComponent(kDefaultStoreName);
        let modelURL = bundle.URLForResource(kDefaultModelName, withExtension: "momd")
        let errorHandler = ServiceLocator.errorHandler()
        
        persistentStack = PersistentStack(storeURL: storeURL, modelURL: modelURL!, errorHandler: errorHandler)
    }
}
