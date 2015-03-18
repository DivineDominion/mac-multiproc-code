//
//  ProvisioningServiceTests.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 04/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class ProvisioningServiceTests: XCTestCase {
    
    let publisher = MockDomainEventPublisher()
    
    let boxRepoDouble = TestBoxRepository()
    let itemRepoDouble = TestItemRepository()
    lazy var provisioningService: ProvisioningService = ProvisioningService(boxRepository: self.boxRepoDouble, itemRepository: self.itemRepoDouble)
    
    class TestIdentityService: IdentityService {
        init() {
            super.init(boxRepository: NullBoxRepository(), itemRepository: NullItemRepository())
        }
        
        var didObtainBoxId = false
        override func nextBoxId() -> BoxId {
            didObtainBoxId = true
            return super.nextBoxId()
        }
        
        var didObtainItemId = false
        override func nextItemId() -> ItemId {
            didObtainItemId = true
            return super.nextItemId()
        }
    }
    
    let identityServiceDouble = TestIdentityService()
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisher)
        provisioningService.identityService = identityServiceDouble
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }

    // MARK: Provisioning Boxes
    
    func provisionIrrelevantBox() {
        provisioningService.provisionBox("irrelevant", capacity: .Small)
    }
    
    func testProbisionBox_ObtainsBoxId() {
        provisionIrrelevantBox()
        
        XCTAssertTrue(identityServiceDouble.didObtainBoxId)
    }
    
    func testProvisionBox_AddsBoxToRepo() {
        provisionIrrelevantBox()
        
        XCTAssertNotNil(boxRepoDouble.lastBoxAdded)
    }
    
    func testProvisionBox_PublishesDomainEvent() {
        provisionIrrelevantBox()
        
        XCTAssert(publisher.lastPublishedEvent != nil)
    }
    
    // MARK: Provisioning Items
    
    let boxDouble = TestBox()
    
    func provisionIrrelevantItem() {
        provisioningService.provisionItem("irrelevant", inBox: boxDouble)
    }
    
    func testProvisionItem_DoesNotObtainItemId() {
        provisionIrrelevantItem()
        
        XCTAssertFalse(identityServiceDouble.didObtainItemId)
    }
    
    func testProvisionItem_CallsItemFactory() {
        provisionIrrelevantItem()
        
        XCTAssertTrue(boxDouble.didCreateItem)
    }
    
    func testProvisionItem_AddsItemToRepo() {
        provisionIrrelevantItem()
        
        let expectedItem = boxDouble.itemStub
        if let lastItemAdded = itemRepoDouble.lastItemAdded {
            XCTAssertEqual(lastItemAdded, expectedItem)
        } else {
            XCTFail("item not added to repo")
        }
    }
    
    func testProvisionItem_PublishesDomainEvent() {
        provisionIrrelevantItem()
        
        XCTAssert(publisher.lastPublishedEvent != nil)
        if let event = publisher.lastPublishedEvent as? ItemProvisioned {
            let expectedItemId = boxDouble.itemStub.itemId
            XCTAssertEqual(event.itemId, expectedItemId)
            
            let expectedItemTitle = boxDouble.itemStub.title
            XCTAssertEqual(event.title, expectedItemTitle)
        } else {
            XCTFail("wrong event")
        }
    }
    
    
    // MARK: -
    // MARK: Test Doubles
    
    class TestBoxRepository: NullBoxRepository {
        var lastBoxAdded: Box?
        override func addBox(box: Box) {
            lastBoxAdded = box
        }
    }
    
    class TestItemRepository: NullItemRepository {
        var lastItemAdded: Item?
        override func addItem(item: Item) {
            lastItemAdded = item
        }
    }

    class TestBox: Box {
        init() {
            super.init(boxId: BoxId(0), capacity: .Medium, title: "irrelevant")
        }
        
        lazy var itemStub: Item = Item(itemId: ItemId(204), title: "irrelevant", boxId: self.boxId)
        var didCreateItem = false
        override func item(itemTitle: String, identityService: IdentityService) -> Item {
            didCreateItem = true
            return itemStub
        }
    }
}
