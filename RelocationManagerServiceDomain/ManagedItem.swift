//
//  ManagedItem.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

private var itemContext = 0

@objc(ManagedItem)
public class ManagedItem: NSManagedObject, ManagedEntity {
    
    @NSManaged public var uniqueId: NSNumber
    @NSManaged public var title: String
    @NSManaged public var creationDate: NSDate
    @NSManaged public var modificationDate: NSDate
    @NSManaged public var box: ManagedBox

    public class func entityName() -> String {
        return "ManagedItem"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }
    
    public class func insertManagedItem(item: Item, managedBox: ManagedBox, inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        let managedItem = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext) as ManagedItem
        
        managedItem.item = item
        managedItem.box = managedBox
    }
    
    public func itemId() -> ItemId {
        return ItemId(self.uniqueId.longLongValue)
    }
    
    //MARK: -
    //MARK: Item Management
    
    private var _item: Item?
    public var item: Item {
        get {
            if let item = _item {
                return item
            }
            
            let item = createItem()
            observe(item)
            _item = item
            
            return item
        }
        set {
            assert(_item == nil, "can be set only during initialization")
            
            let item = newValue
            adaptItem(item)
            observe(item)
            
            _item = item
        }
    }
    
    func createItem() -> Item {
        return Item(itemId: self.itemId(), title: self.title)
    }
    
    func adaptItem(item: Item) {
        uniqueId = item.itemId.number
        title = item.title
    }
    
    
    // MARK: OBserving Changes
    
    func observe(item: Item) {
        // TODO add back-reference to box
        item.addObserver(self, forKeyPath: "title", options: .New, context: &itemContext)
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if context != &itemContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            let newTitle = change[NSKeyValueChangeNewKey] as String
            self.title = newTitle
        }
    }
    
    // MARK: Destructor
    
    deinit {
        if let item = _item {
            unobserve(item)
        }
    }
    
    func unobserve(item: Item) {
        item.removeObserver(self, forKeyPath: "title")
    }
}
