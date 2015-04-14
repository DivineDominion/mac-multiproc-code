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
    @NSManaged public var managedBoxId: NSNumber

    public class func entityName() -> String {
        return "ManagedItem"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }
    
    public class func insertManagedItem(item: Item,inManagedObjectContext managedObjectContext:NSManagedObjectContext) {
        let managedItem = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext) as! ManagedItem
        
        managedItem.item = item
    }
    
    public var itemId: ItemId {
        return ItemId(uniqueId.longLongValue)
    }
    
    public var boxId: BoxId {
        return BoxId(managedBoxId.longLongValue)
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
        return Item(itemId: self.itemId, title: self.title, boxId: self.boxId)
    }
    
    func adaptItem(item: Item) {
        uniqueId = item.itemId.number
        title = item.title
        managedBoxId = item.boxId.number
    }
    
    
    // MARK: Observing Changes
    
    func observe(item: Item) {
        item.addObserver(self, forKeyPath: "title", options: .New, context: &itemContext)
        item.addObserver(self, forKeyPath: "boxIdentifier", options: .New, context: &itemContext)
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if context != &itemContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            let newTitle = change[NSKeyValueChangeNewKey] as! String
            self.title = newTitle
        } else if keyPath == "boxIdentifier" {
            let newIdentifier = change[NSKeyValueChangeNewKey] as! NSNumber
            self.managedBoxId = newIdentifier
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
