//
//  ManagedBoxTests.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 27.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class ManagedBoxTests: CoreDataTestCase {
    
    var repository: CoreDataBoxRepository?
    
    override func setUp() {
        super.setUp()
        repository = CoreDataBoxRepository(managedObjectContext: context)
    }
    
    func soleManagedBox() -> ManagedBox? {
        return allBoxes()?.first
    }
    
    func allBoxes() -> [ManagedBox]? {
        let request = NSFetchRequest(entityName: ManagedBox.entityName())
        return context.executeFetchRequest(request, error: nil) as [ManagedBox]?
    }
    
    func allItems() -> [ManagedItem]? {
        let request = NSFetchRequest(entityName: ManagedItem.entityName())
        return context.executeFetchRequest(request, error: nil) as [ManagedItem]?
    }
    
    func box() -> Box {
        return box(BoxId(456))
    }
    
    func box(boxId: BoxId) -> Box {
        return Box(boxId: boxId, capacity: .Small, title: "the title")
    }
    
    // MARK: Wrapping/Observing Box
    
    func testInsertingManagedBox_AdaptsAllValues() {
        let theBox = box()
        ManagedBox.insertManagedBox(theBox, inManagedObjectContext: context)
        
        if let managedBox = soleManagedBox() {
            XCTAssertEqual(managedBox.title, theBox.title)
            XCTAssertEqual(managedBox.capacity, theBox.capacity.rawValue)
            XCTAssertEqual(managedBox.uniqueId, theBox.boxId.number)
        } else {
            XCTFail("inserting/fetching box failed")
        }
    }
        
    func testChangingOriginalBoxTitle_PersistsChanges() {
        let theBox = box()
        ManagedBox.insertManagedBox(theBox, inManagedObjectContext: context)
        
        theBox.title = "new title"
        
        let foundBox = allBoxes()!.first! as ManagedBox
        XCTAssertEqual(foundBox.title, "new title")
    }
    
    func testChangingOriginalLocking_PersistsChanges() {
        let theBox = box()
        ManagedBox.insertManagedBox(theBox, inManagedObjectContext: context)
        
        theBox.lock()
        
        let foundBox = allBoxes()!.first! as ManagedBox
        XCTAssertTrue(foundBox.isLocked.boolValue)
    }
    
    
    // MARK: Title changes

    func testChangingFetchedBoxTitle_PersistsChanges() {
        let boxId = BoxId(1234)
        ManagedBox.insertManagedBox(box(boxId), inManagedObjectContext: context)
        
        if let box = repository!.box(boxId: boxId) {
            box.title = "new title"

            let foundBox = allBoxes()!.first! as ManagedBox
            XCTAssertEqual(foundBox.title, "new title")
        } else {
            XCTFail("box not found")
        }
    }
    
    func testChangingFetchedBoxTitle_ToEmptyString_PersistsChanges() {
        let boxId = BoxId(1234)
        ManagedBox.insertManagedBox(box(boxId), inManagedObjectContext: context)
        
        if let box = repository!.box(boxId: boxId) {
            box.title = ""
            
            let foundBox = allBoxes()!.first! as ManagedBox
            XCTAssertEqual(foundBox.title, "")
        } else {
            XCTFail("box not found")
        }
    }

}
