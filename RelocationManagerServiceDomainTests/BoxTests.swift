//
//  BoxTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 23/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class BoxTests: XCTestCase {
    let publisher = MockDomainEventPublisher()
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }
    
    func emptyBox() -> Box {
        return Box(boxId: BoxId(0), capacity: .Small, title: "irrelevant")
    }
    
    func item() -> Item {
        return Item(itemId: ItemId(1), title: "irrelevant item")
    }
    
    func fullBox() -> Box {
        let box = emptyBox()
        
        for index in 1...box.capacity.rawValue {
            box.addItem(item())
        }
        
        return box
    }
    
    
    // MARK: - Creation
    
    func testCreatingBox_StartsWithFullRemainingCapacity() {
        let box = emptyBox()
        
        XCTAssertEqual(box.remainingCapacity, box.capacity.rawValue)
    }
    
    
    // MARK: -
    // MARK: Adding items
    
    func testAddingItem_ReducesRemainingCapacity() {
        let box = emptyBox()
        
        box.addItem(item())
        
        XCTAssertEqual(box.remainingCapacity, box.capacity.rawValue - 1)
    }
    
    func testAddingItem_PublishesSuccessEvent() {
        let box = emptyBox()
        
        box.addItem(item())
        
        if let event = publisher.lastPublishedEvent as? BoxItemAdded {
            XCTAssertEqual(event.boxId, box.boxId)
        } else {
            XCTFail("did not publish success event")
        }
    }
    
    func testAddingItem_ToFullBox_DoesntAddTheItem() {
        let box = fullBox()
        let itemId = ItemId(2)
        let item = Item(itemId: itemId, title: "different item")
        
        box.addItem(item)
        
        XCTAssertNil(box.item(itemId: itemId), "new item should not be added")
    }
    
    func testAddingItem_ToFullBox_PublishesFailureEvent() {
        let box = fullBox()
        let itemId = ItemId(2)
        let itemTitle = "different item"
        let item = Item(itemId: itemId, title: itemTitle)
        
        box.addItem(item)
        
        if let event = publisher.lastPublishedEvent as? AddingBoxItemFailed {
            XCTAssertEqual(event.boxId, box.boxId)
            XCTAssertEqual(event.itemId, itemId)
            XCTAssertEqual(event.itemTitle, itemTitle)
        } else {
            XCTFail("did not publish failure event")
        }
    }
    
    
    // MARK: Filled status
    
    func testFilledBox_IsFull() {
        let box = fullBox()
        
        XCTAssert(box.isFull())
    }
    
    func testFilledBox_HasNoRemainingCapacity() {
        let box = fullBox()
        
        XCTAssertEqual(box.remainingCapacity, 0)
    }
    
}
