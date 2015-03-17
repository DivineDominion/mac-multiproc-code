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
    let box = Box(boxId: BoxId(0), capacity: .Small, title: "the box")
    
    // MARK: Locking
    
    func testLocking_Locks() {
        box.lock()
        
        XCTAssertTrue(box.locked)
    }
    
    func testUnlockingAfterLocking_Unlocks() {
        box.lock()
        box.unlock()
        
        XCTAssertFalse(box.locked)
    }
    
    // MARK: Dissolving
    
    func testDissolving_DelegatesToService() {
        let redistributionService = TestRedistributionService()
        
        box.dissolve(redistributionService)
        
        XCTAssertTrue(redistributionService.didRedistribute)
    }
    
    class TestRedistributionService: RedistributesItems {
        var didRedistribute = false
        func redistributeItems(box: Box) {
            didRedistribute = true
        }
    }
}
