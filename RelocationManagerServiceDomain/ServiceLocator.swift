//
//  ServiceLocator.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

private struct ServiceLocatorStatic {
    static var singleton: ServiceLocator? = nil
    static var onceToken: dispatch_once_t = 0
}

public class ServiceLocator {
    
    public init() { }
    public class var sharedInstance: ServiceLocator {
        
        if ServiceLocatorStatic.singleton == nil {
            dispatch_once(&ServiceLocatorStatic.onceToken) {
                self.setSharedInstance(ServiceLocator())
            }
        }
        
        return ServiceLocatorStatic.singleton!
    }
    
    /// Reset the static `sharedInstance`, for example for testing
    public class func resetSharedInstance() {
        ServiceLocatorStatic.singleton = nil
        ServiceLocatorStatic.onceToken = 0
    }
    
    public class func setSharedInstance(instance: ServiceLocator) {
        ServiceLocatorStatic.singleton = instance
    }
    
    var managedObjectContext: NSManagedObjectContext?
    
    public func setManagedObjectContext(managedObjectContext: NSManagedObjectContext) {
        assert(self.managedObjectContext == nil, "managedObjectContext can be set up only once")
        self.managedObjectContext = managedObjectContext
    }
    
    func guardManagedObjectContext() {
        assert(managedObjectContext != nil, "managedObjectContext must be set up")
    }
    
    // MARK: Transaction
    
    public class func unitOfWork() -> UnitOfWork {
        return sharedInstance.unitOfWork()
    }
    
    // TODO: move ErrorHandler into persistent stack
    var errorHandler = ErrorHandler()
    public func unitOfWork() -> UnitOfWork {
        guardManagedObjectContext()
        return UnitOfWork(managedObjectContext: managedObjectContext!, errorHandler: errorHandler)
    }
    
    
    // MARK: Repository Access
    
    public class func boxRepository() -> BoxRepository {
        return sharedInstance.boxRepository()
    }
    
    public func boxRepository() -> BoxRepository {
        guardManagedObjectContext()
        return CoreDataBoxRepository(managedObjectContext: managedObjectContext!)
    }
    
    
    public class func itemRepository() -> ItemRepository {
        return sharedInstance.itemRepository()
    }
    
    public func itemRepository() -> ItemRepository {
        guardManagedObjectContext()
        return CoreDataItemRepository(managedObjectContext: managedObjectContext!)
    }
}
