//
//  ManagedItemTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 10/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class ManagedItemTests: CoreDataTestCase {
    
    var repository: CoreDataBoxRepository?
    
    override func setUp() {
        super.setUp()
        repository = CoreDataBoxRepository(managedObjectContext: context)
    }

    func item() -> Item {
        return Item(itemId: ItemId(3344), title: "the title", boxId: BoxId(0))
    }
    
    func irrelevantManagedBox(boxId: BoxId) -> ManagedBox? {
        let box = Box(boxId: boxId, capacity: .Medium, title: "irrelevant")
        ManagedBox.insertManagedBox(box, inManagedObjectContext: context)
        
        let request = NSFetchRequest(entityName: ManagedBox.entityName())
        let allBoxes = context.executeFetchRequest(request, error: nil) as [ManagedBox]?
        
        return allBoxes?.first
    }
    
    func soleManagedItem() -> ManagedItem? {
        return allItems()?.first
    }
    
    func allItems() -> [ManagedItem]? {
        let request = NSFetchRequest(entityName: ManagedItem.entityName())
        return context.executeFetchRequest(request, error: nil) as [ManagedItem]?
    }
    
    // MARK: Insertion
    
    func testInsertingManagedItem_AdaptsAllValues() {
        let theItem = item()
        ManagedItem.insertManagedItem(theItem,inManagedObjectContext: context)
        
        if let managedItem = soleManagedItem() {
            XCTAssertEqual(managedItem.title, theItem.title)
            XCTAssertEqual(managedItem.uniqueId, theItem.itemId.number)
            XCTAssertEqual(managedItem.boxId, theItem.boxId)
        } else {
            XCTFail("inserting/fetching item failed")
        }
    }

    // MARK: Adapting Item Changes
    
    func testMovingItem_PersistsBoxId() {
        let theItem = item()
        ManagedItem.insertManagedItem(theItem,inManagedObjectContext: context)
        
        theItem.moveToBox(boxId: BoxId(999))
        
        if let managedItem = soleManagedItem() {
            XCTAssertEqual(managedItem.boxId, theItem.boxId)
        } else {
            XCTFail("inserting/fetching item failed")
        }
    }
    
    func testChangingTitle_PersistsChanges() {
        let theItem = item()
        ManagedItem.insertManagedItem(theItem,inManagedObjectContext: context)
        
        theItem.title = "new title"
        
        if let managedItem = soleManagedItem() {
            XCTAssertEqual(managedItem.title, theItem.title)
        } else {
            XCTFail("inserting/fetching item failed")
        }
    }
}
