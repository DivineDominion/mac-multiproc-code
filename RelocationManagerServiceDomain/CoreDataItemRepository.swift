//
//  CoreDataItemRepository.swift
//  RelocationManager
//
//  Created by Christian Tietze on 09/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataItemRepository: NSObject, ItemRepository {
    let managedObjectContext: NSManagedObjectContext
    let integerIdGenerator: GeneratesIntegerId
    
    public convenience init(managedObjectContext: NSManagedObjectContext) {
        self.init(managedObjectContext: managedObjectContext, integerIdGenerator: DefaultIntegerIdGenerator())
    }
    
    public init(managedObjectContext: NSManagedObjectContext, integerIdGenerator: GeneratesIntegerId) {
        self.managedObjectContext = managedObjectContext
        self.integerIdGenerator = integerIdGenerator
        
        super.init()
    }
    
    
    //MARK: -
    //MARK: CRUD Actions
    
    public func addItem(item: Item) {
        // TODO add addItem: using fetch requests to obtain ManagedBox
//        let box = ServiceLocator.sharedInstance.boxRepository().box(boxId: item.boxId)
//        ManagedItem.insertManagedItem(item: Item, managedBox: managedBox, inManagedObjectContext: managedObjectContext)
    }
    
    public func items() -> [Item] {
        let fetchRequest = NSFetchRequest(entityName: ManagedItem.entityName())
        fetchRequest.includesSubentities = true
        
        var error: NSError? = nil
        let results = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        
        if results == nil {
            logError(error!, operation: "find existing items")
            postReadErrorNotification()
            assert(false, "error fetching items")
            return []
        }
        
        let managedItems: [ManagedItem] = results as [ManagedItem]
        
        return managedItems.map({ (managedItem: ManagedItem) -> Item in
            return managedItem.item
        })
    }
    
    public func count() -> Int {
        let fetchRequest = NSFetchRequest(entityName: ManagedItem.entityName())
        fetchRequest.includesSubentities = false
        
        var error: NSError? = nil
        let count = managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        
        if count == NSNotFound {
            logError(error!, operation: "fetching item count")
            postReadErrorNotification()
            assert(false, "error fetching count")
            return NSNotFound
        }
        
        return count
    }
    
    
    // MARK: Item ID Generation
    
    public func nextId() -> ItemId {
        let hasManagedBoxWithUniqueId: (IntegerId) -> Bool = { identifier in
            return self.managedItemWithUniqueId(identifier) != nil
        }
        let generator = IdGenerator<ItemId>(integerIdGenerator: integerIdGenerator, integerIdIsTaken: hasManagedBoxWithUniqueId)
        return generator.nextId()
    }
    
    func managedItemWithUniqueId(identifier: IntegerId) -> ManagedItem? {
        let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        let templateName = "ManagedItemWithUniqueId"
        let fetchRequest = managedObjectModel.fetchRequestFromTemplateWithName(templateName, substitutionVariables: ["IDENTIFIER": NSNumber(longLong: identifier)])
        
        assert(fetchRequest != nil, "Fetch request named 'ManagedItemWithUniqueId' is required")
        
        var error: NSError? = nil
        let result = managedObjectContext.executeFetchRequest(fetchRequest!, error:&error);
        
        if result == nil {
            logError(error!, operation: "find existing item with ID '\(identifier)'")
            postReadErrorNotification()
            assert(false, "error fetching item with id")
            return nil
        }
        
        if result!.count == 0 {
            return nil
        }
        
        return result![0] as? ManagedItem
    }
 
    
    //MARK: -
    //MARK: Error Handling
    
    func logError(error: NSError, operation: String) {
        NSLog("Failed to \(operation): \(error.localizedDescription)")
        logDetailledErrors(error)
    }
    
    var notificationCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    func postReadErrorNotification() {
        notificationCenter.postNotificationName(kCoreDataReadErrorNotificationName, object: self)
    }
}