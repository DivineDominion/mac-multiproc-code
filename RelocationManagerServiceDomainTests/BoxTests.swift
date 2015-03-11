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

class TestBoxFactory {
    let itemRepository = InstantFullItemRepository()
    
    func registerItemRepository(registry: TestDomainRegistry) {
        registry.testItemRepository = itemRepository
    }
    
    var identifier: IntegerId = 0
    func emptyBox() -> Box {
        return Box(boxId: BoxId(identifier++), capacity: .Small, title: "irrelevant")
    }
    
    func fullBox() -> Box {
        let box = emptyBox()
        
        itemRepository.fillBox(box)
        
        return box
    }
    
    class InstantFullItemRepository: NullItemRepository {
        var items = [IntegerId : [Item]]()
        override func items(#boxId: BoxId) -> [Item] {
            if let items = items[boxId.identifier] {
                return items
            }
            
            return []
        }
        
        func fillBox(box: Box) {
            var boxItems = [Item]()
            
            for index in 1...box.capacity.rawValue {
                boxItems.append(item(box))
            }
            
            items[box.boxId.identifier] = boxItems
        }
        
        private func item(box: Box) -> Item {
            return Item(itemId: ItemId(1), title: "irrelevant item", boxId: box.boxId)
        }
    }
}

class BoxTests: XCTestCase {
    let boxFactory = TestBoxFactory()
    let registry = TestDomainRegistry()
    let publisher = MockDomainEventPublisher()
    
    override func setUp() {
        super.setUp()
        boxFactory.registerItemRepository(registry)
        DomainRegistry.setSharedInstance(registry)
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        DomainRegistry.resetSharedInstance()
        super.tearDown()
    }

    func emptyBox() -> Box {
        return boxFactory.emptyBox()
    }
    
    func fullBox() -> Box {
        return boxFactory.fullBox()
    }
    
    // MARK: Creation
    
    func testCreatingBox_StartsWithFullRemainingCapacity() {
        let box = emptyBox()
        
        XCTAssertEqual(box.remainingCapacity, box.capacity.rawValue)
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
