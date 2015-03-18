//
//  IdentityServiceTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class IdentityServiceTests: XCTestCase {
    class TestBoxRepository: NullBoxRepository {
        var testBoxId = BoxId(0)
        var didCallNextId = false
        override func nextId() -> BoxId {
            didCallNextId = true
            return testBoxId
        }
    }
    
    class TestItemRepository: NullItemRepository {
        var testItemId = ItemId(0)
        var didCallNextId = false
        override func nextId() -> ItemId {
            didCallNextId = true
            return testItemId
        }
    }
    
    let boxRepoDouble = TestBoxRepository()
    let itemRepoDouble = TestItemRepository()
    lazy var identityService: IdentityService = IdentityService(boxRepository: self.boxRepoDouble, itemRepository: self.itemRepoDouble)
    
    func testNextBoxId_DelegatesToBoxRepo() {
        let expectedBoxId = BoxId(123)
        boxRepoDouble.testBoxId = expectedBoxId
        
        let boxId = identityService.nextBoxId()
        
        XCTAssertTrue(boxRepoDouble.didCallNextId)
        XCTAssertEqual(boxId, expectedBoxId)
    }

    func testNextItemId_DelegatesToItemRepo() {
        let expectedItemId = ItemId(445)
        itemRepoDouble.testItemId = expectedItemId
        
        let itemId = identityService.nextItemId()
        
        XCTAssertTrue(itemRepoDouble.didCallNextId)
        XCTAssertEqual(itemId, expectedItemId)
    }
}
