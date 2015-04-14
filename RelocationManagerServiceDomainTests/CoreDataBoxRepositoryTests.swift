//
//  CoreDataBoxRepositoryTests.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 16.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class CoreDataBoxRepositoryTests: CoreDataTestCase {
    var repository: CoreDataBoxRepository?
    
    override func setUp() {
        super.setUp()
        
        repository = CoreDataBoxRepository(managedObjectContext: context)
    }
    
    func allBoxes() -> [ManagedBox]? {
        let request = NSFetchRequest(entityName: ManagedBox.entityName())
        return context.executeFetchRequest(request, error: nil) as! [ManagedBox]?
    }

    //MARK: Adding Entities

    func testAddingBox_InsertsEntityIntoStore() {
        let title = "a title"
        let boxId = repository!.nextId()
        let capacity = BoxCapacity.Medium
        let box = Box(boxId: boxId, capacity: capacity, title: title)
    
        repository!.addBox(box)

        let boxes = self.allBoxes()!
        XCTAssert(boxes.count > 0, "items expected")
        
        if let managedBox = boxes.first {
            XCTAssertEqual(managedBox.title, title, "Title should be saved")
            XCTAssertEqual(managedBox.capacity, capacity.rawValue)
            XCTAssertEqual(managedBox.boxId, boxId, "Box ID should be saved")
        }
    }

    //MARK: Generating IDs
    
    func testNextId_WhenGeneratedIdIsTaken_ReturnsAnotherId() {
        let testGenerator = TestIntegerIdGenerator()
        repository = CoreDataBoxRepository(managedObjectContext: context, integerIdGenerator: testGenerator)
        let existingId = BoxId(testGenerator.firstAttempt)
        let existingBox = Box(boxId: existingId, capacity: .Small, title: "irrelevant")
        ManagedBox.insertManagedBox(existingBox, inManagedObjectContext: context)
        
        let boxId = repository!.nextId()
        
        let expectedNextId = BoxId(testGenerator.secondAttempt)
        XCTAssertEqual(boxId, expectedNextId, "Should generate another ID because first one is taken")
    }
}
