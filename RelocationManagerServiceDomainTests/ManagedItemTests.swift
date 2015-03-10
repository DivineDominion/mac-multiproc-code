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
        return Item(itemId: ItemId(3344), title: "the title")
    }
    
    func irrelevantManagedBox() -> ManagedBox? {
        let box = Box(boxId: BoxId(123), capacity: .Medium, title: "irrelevant")
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
    
    func testInsertingManagedItem_AdaptsAllValues() {
        let managedBox = irrelevantManagedBox()
        let theItem = item()
        ManagedItem.insertManagedItem(theItem, managedBox: managedBox!, inManagedObjectContext: context)
        
        if let managedItem = soleManagedItem() {
            XCTAssertEqual(managedItem.title, theItem.title)
            XCTAssertEqual(managedItem.uniqueId, theItem.itemId.number)
        } else {
            XCTFail("inserting/fetching item failed")
        }
    }

}
