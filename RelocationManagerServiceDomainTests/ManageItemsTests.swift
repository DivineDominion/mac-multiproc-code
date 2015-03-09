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
    class TestDistributeItem: NullDistributeItem {
        var didDistributeItem = false
        var itemTitle: String?
        override func distribute(itemTitle title: String) {
            
            self.itemTitle = title
            didDistributeItem = true
        }
    }
    
    lazy var service: ManageItems = ManageItems()
    
    let distributionService = TestDistributeItem()
    let provisioningService: TestProvisioningService = TestProvisioningService()
    
    let registry = TestDomainRegistry()
    let publisher = DomainEventPublisher(notificationCenter: NSNotificationCenter())

    
    override func setUp() {
        super.setUp()
        
        registry.testDistributeItem = distributionService
        DomainRegistry.setSharedInstance(registry)
        
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        DomainRegistry.resetSharedInstance()
        
        super.tearDown()
    }
    
    // MARK: Reacting to Domain Events
    
    func testAddingFailed_InvokesAnotherDistribution() {
        let irrelevantBoxId = BoxId(101)
        let irrelevantItemId = ItemId(202)
        let itemTitle = "the title"
        let service = self.service // force lazy init
        
        publisher.publish(AddingBoxItemFailed(boxId: irrelevantBoxId, itemId: irrelevantItemId, itemTitle: itemTitle))
        
        XCTAssertTrue(distributionService.didDistributeItem)
        if distributionService.didDistributeItem {
            XCTAssertEqual(distributionService.itemTitle!, itemTitle)
        }
    }
    
    // MARK: Provision Item
    
    func testProvisionItem_DelegatesToDistributionService() {
        let itemTitle = "the name"
        
        service.distributeItem(itemTitle)
        
        XCTAssertTrue(distributionService.didDistributeItem)
        if distributionService.didDistributeItem {
            XCTAssertEqual(distributionService.itemTitle!, itemTitle)
        }
    }
}

