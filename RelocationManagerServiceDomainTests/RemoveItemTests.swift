//
//  RemoveItemTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class RemoveItemTests: XCTestCase {

    let publisher = MockDomainEventPublisher()
    
    let itemRepoDouble = TestItemRepository()
    lazy var service: RemoveItem = RemoveItem(itemRepository: self.itemRepoDouble)
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }
    
    
    // MARK: Item Removal Failure

    func testRemoveItem_WhichDoesntExist_PublishesFailure() {
        let itemId = ItemId(100)
        let boxId = BoxId(0)
        itemRepoDouble.doNotFindItem()
        
        service.remove(itemId, fromBox: boxId)
        
        XCTAssertTrue(failureEventMatches(itemId, boxId))
    }
    
    func testRemoveItem_WhichDoesExistInDifferentBox_PublishesFailure() {
        let itemId = ItemId(100)
        let realBoxId = BoxId(1)
        let expectedBoxId = BoxId(2)
        itemRepoDouble.findItem(itemId, realBoxId)
        
        service.remove(itemId, fromBox: expectedBoxId)
        
        XCTAssertTrue(failureEventMatches(itemId, expectedBoxId))
    }
    
    func failureEventMatches(itemId: ItemId, _ boxId: BoxId) -> Bool {
        if let event = publisher.lastPublishedEvent as? ItemRemovalFailed {
            return event.itemId == itemId && event.boxId == boxId
        }
        
        return false
    }

    // MARK: Item Removal Success
    
    func testRemoveItem_WhichExistsInTheBox_RemovesFromRepo() {
        let itemId = ItemId(100)
        let boxId = BoxId(55)
        itemRepoDouble.findItem(itemId, boxId)
        
        service.remove(itemId, fromBox: boxId)
        
        XCTAssertTrue(itemRepoDouble.didRemoveItem)
        if itemRepoDouble.didRemoveItem {
            XCTAssertEqual(itemRepoDouble.removedItemId!, itemId)
        }
    }

    func testRemoveItem_WhichExistsInTheBox_PublishesEvent() {
        let itemId = ItemId(100)
        let boxId = BoxId(55)
        itemRepoDouble.findItem(itemId, boxId)
        
        service.remove(itemId, fromBox: boxId)
        
        XCTAssertTrue(successEventMatches(itemId))
    }

    func successEventMatches(itemId: ItemId) -> Bool {
        if let event = publisher.lastPublishedEvent as? ItemRemoved {
            return event.itemId == itemId
        }
        
        return false
    }


    // MARK: Test Doubles
    
    class TestItemRepository: NullItemRepository {
        private(set) var didRemoveItem = false
        private(set) var removedItemId: ItemId?
        override func removeItem(#itemId: ItemId) {
            didRemoveItem = true
            removedItemId = itemId
        }
        
        private(set) var foundItem: Item? = nil
        override func item(#itemId: ItemId) -> Item? {
            return foundItem
        }
        
        func doNotFindItem() {
            foundItem = nil
        }
        
        func findItem(itemId: ItemId, _ boxId: BoxId) {
            foundItem = Item(itemId: itemId, title: "irrelevant", boxId: boxId)
        }
    }
}
