//
//  ManagedBox.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

private var boxContext = 0

@objc(ManagedBox)
public class ManagedBox: NSManagedObject, ManagedEntity {

    @NSManaged public var creationDate: NSDate
    @NSManaged public var modificationDate: NSDate
    @NSManaged public var title: String
    @NSManaged public var capacity: NSNumber
    @NSManaged public var uniqueId: NSNumber
    @NSManaged public var items: NSSet
    
    public class func entityName() -> String {
        return "ManagedBox"
    }
    
    public class func entityDescriptionInManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }
    
    public class func insertManagedBox(box: Box, inManagedObjectContext managedObjectContext: NSManagedObjectContext) {
        
        let managedBox = NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedObjectContext) as! ManagedBox
        
        managedBox.box = box
    }
        
    public var boxId: BoxId {
        return BoxId(uniqueId.longLongValue)
    }
    
    
    //MARK: -
    //MARK: Box Management
    
    private var _box: Box?
    public var box: Box {
        get {
            if let box = _box {
                return box
            }
            
            let box = createBox()
            observe(box)
            _box = box
            
            return box
        }
        set {
            assert(_box == nil, "can be set only during initialization")
            
            let box = newValue
            adaptBox(box)
            observe(box)
            
            _box = box
        }
    }
    
    func createBox() -> Box {
        let box = Box(boxId: self.boxId, capacity: self.boxCapacity, title: self.title)
        return box
    }
    
    func adaptBox(box: Box) {
        uniqueId = box.boxId.number
        title = box.title
        capacity = box.capacity.rawValue
    }
    
    public lazy var boxCapacity: BoxCapacity = {
        let capacity = BoxCapacity(rawValue: self.capacity.integerValue)
        assert(capacity != nil, "invalid box capacity: \(self.capacity)")
        return capacity!
    }()
    
    func associatedItems() -> [Item] {
        let managedItems = self.items.allObjects as! [ManagedItem]
        return managedItems.map() { (item: ManagedItem) -> Item in
            return item.item
        }
    }
    
    // MARK: Observing Changes
    
    func observe(box: Box) {
        box.addObserver(self, forKeyPath: "title", options: .New, context: &boxContext)
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if context != &boxContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            let newTitle = change[NSKeyValueChangeNewKey] as! String
            self.title = newTitle
        }
    }
    
    // MARK: Destructor
    
    deinit {
        if let box = _box {
            unobserve(box)
        }
    }

    func unobserve(box: Box) {
        box.removeObserver(self, forKeyPath: "title")
    }
}
