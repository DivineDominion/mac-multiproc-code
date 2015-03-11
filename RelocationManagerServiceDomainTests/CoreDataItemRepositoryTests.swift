//
//  CoreDataItemRepositoryTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 09/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class CoreDataItemRepositoryTests: CoreDataTestCase {
    var repository: CoreDataItemRepository?
    
    override func setUp() {
        super.setUp()
        
        repository = CoreDataItemRepository(managedObjectContext: context)
    }
    
    func allBoxes() -> [ManagedBox]? {
        let request = NSFetchRequest(entityName: ManagedBox.entityName())
        return context.executeFetchRequest(request, error: nil) as [ManagedBox]?
    }
    
    func allItems() -> [ManagedItem]? {
        let request = NSFetchRequest(entityName: ManagedItem.entityName())
        return context.executeFetchRequest(request, error: nil) as [ManagedItem]?
    }
    
    //MARK: Generating IDs
    
    func testNextId_WhenGeneratedIdIsTaken_ReturnsAnotherId() {
        let testGenerator = TestIntegerIdGenerator()
        repository = CoreDataItemRepository(managedObjectContext: context, integerIdGenerator: testGenerator)
        let box = Box(boxId: BoxId(0), capacity: .Small, title: "irrelevant")
        ManagedBox.insertManagedBox(box, inManagedObjectContext: context)
        let managedBox = allBoxes()!.first!
        let existingId = ItemId(testGenerator.firstAttempt)
        let item = Item(itemId: existingId, title: "irrelevant", boxId: box.boxId)
        ManagedItem.insertManagedItem(item, inManagedObjectContext: context)
        
        let itemId = repository!.nextId()
        
        let expectedNextId = ItemId(testGenerator.secondAttempt)
        XCTAssertEqual(itemId, expectedNextId, "Should generate another ID because first one is taken")
    }
}
