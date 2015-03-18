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
    
    func testProvisionItem_CallsItemFactoryWithIdentityService() {
        provisionIrrelevantItem()
        
        XCTAssertTrue(boxDouble.didCreateItem)
        if boxDouble.didCreateItem && boxDouble.identityServiceUsed !== identityServiceDouble {
            XCTFail("wrong identity service used")
        }
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
        private(set) var lastBoxAdded: Box?
        override func addBox(box: Box) {
            lastBoxAdded = box
        }
    }
    
    class TestItemRepository: NullItemRepository {
        private(set) var lastItemAdded: Item?
        override func addItem(item: Item) {
            lastItemAdded = item
        }
    }

    class TestBox: Box {
        convenience init() {
            self.init(boxId: BoxId(0), capacity: .Medium, title: "irrelevant")
        }
        
        lazy var itemStub: Item = Item(itemId: ItemId(204), title: "irrelevant", boxId: self.boxId)
        private(set) var didCreateItem = false
        private(set) var identityServiceUsed: IdentityService? = nil
        override func item(itemTitle: String, identityService: IdentityService) -> Item {
            didCreateItem = true
            identityServiceUsed = identityService
            return itemStub
        }
    }
}
