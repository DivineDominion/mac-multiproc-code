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

    func testCreatingBox_StartsWithFullRemainingCapacity() {
        let box = emptyBox()
        
        XCTAssertEqual(box.remainingCapacity, box.capacity.rawValue)
    }
    
    func testAddingItem_ReducesRemainingCapacity() {
        let box = emptyBox()
        
        box.addItem(item())
        
        XCTAssertEqual(box.remainingCapacity, box.capacity.rawValue - 1)
    }
    
    func emptyBox() -> Box {
        return Box(boxId: BoxId(0), capacity: .Small, title: "irrelevant")
    }
    
    func item() -> Item {
        return Item(itemId: ItemId(1), title: "irrelevant item")
    }
    
    func testFilledBox_IsFull() {
        let box = fullBox()
        
        XCTAssert(box.isFull())
    }
    
    func testFilledBox_HasNoRemainingCapacity() {
        let box = fullBox()
        
        XCTAssertEqual(box.remainingCapacity, 0)
    }
    
    func fullBox() -> Box {
        let box = emptyBox()
        
        for index in 1...box.capacity.rawValue {
            box.addItem(item())
        }
        
        return box
    }
    
    func testAddingItem_ToFullBox_DoesntAddTheItem() {
        let box = fullBox()
        let itemId = ItemId(2)
        let item = Item(itemId: itemId, title: "different item")
        
        box.addItem(item)
        
        XCTAssertNil(box.item(itemId: itemId), "new item should not be added")
    }
}
