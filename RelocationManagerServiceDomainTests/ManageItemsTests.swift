//
//  ManageBoxesAndItemsTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 03/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

/// Integration Tests
class ManageItemsTests: XCTestCase {
    
    lazy var service: ManageItems = ManageItems()
    
    let distributionDouble = TestDistributeItem()
    let removalDouble = TestRemoveItem()
    let registry = TestDomainRegistry()
    
    override func setUp() {
        super.setUp()
        
        NullServiceLocator.registerAsSharedInstance()
        
        registry.testDistributeItem = distributionDouble
        registry.testRemoveItem = removalDouble
        DomainRegistry.setSharedInstance(registry)
    }
    
    override func tearDown() {
        DomainRegistry.resetSharedInstance()
        NullServiceLocator.resetSharedInstance()
        
        super.tearDown()
    }
    
    // MARK: Provision Item
    
    func testProvisionItem_DelegatesToDistributionService() {
        let itemTitle = "the name"
        
        service.distributeItem(itemTitle)
        
        XCTAssertTrue(distributionDouble.didDistributeItem)
        if distributionDouble.didDistributeItem {
            XCTAssertEqual(distributionDouble.itemTitle!, itemTitle)
        }
    }
    
    // MARK: Remove Item
    
    func testRemoveItem_DelegatesToRemovalService() {
        service.removeItem(123, fromBoxIdentifier: 456)
        
        if let removal = removalDouble.lastRemoval {
            XCTAssertEqual(removal.itemId, ItemId(123))
            XCTAssertEqual(removal.boxId, BoxId(456))
        } else {
            XCTFail("removal not invoked")
        }
    }
    
    
    // MARK: -
    // MARK: Test Doubles
    
    class TestDistributeItem: NullDistributeItem {
        var didDistributeItem = false
        var itemTitle: String?
        override func distribute(itemTitle title: String) {
            
            self.itemTitle = title
            didDistributeItem = true
        }
    }
    
    class TestRemoveItem: NullRemoveItem {
        struct LastRemoval {
            let itemId: ItemId
            let boxId: BoxId
        }
        
        var lastRemoval: LastRemoval? = nil
        override func remove(itemId: ItemId, fromBox boxId: BoxId) {
            lastRemoval = LastRemoval(itemId: itemId, boxId: boxId)
        }
    }
}

