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
    
    let boxRepository = TestBoxRepository()
    let itemRepository = TestItemRepository()
    let publisher = MockDomainEventPublisher()
    lazy var provisioningService: ProvisioningService = ProvisioningService(boxRepository: self.boxRepository, itemRepository: self.itemRepository)
    
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }

    // MARK: Provisioning Boxes
    
    func provisionIrrelevantBox() {
        provisioningService.provisionBox("irrelevant", capacity: .Small)
    }
    
    func testProvisionBox_AddsBoxToRepo() {
        provisionIrrelevantBox()
        
        XCTAssertNotNil(boxRepository.lastBoxAdded)
    }
    
    func testProvisionBox_PublishesDomainEvent() {
        provisionIrrelevantBox()
        
        XCTAssert(publisher.lastPublishedEvent != nil)
    }
    
    // MARK: Provisioning Items

    func provisionIrrelevantItem() {
        let box = Box(boxId: BoxId(0), capacity: .Medium, title: "irrelevant")
        provisioningService.provisionItem("irrelevant", inBox: box)
    }
    
    func testProvisionItem_AddsItemToRepo() {
        provisionIrrelevantItem()
        
        XCTAssertNotNil(itemRepository.lastItemAdded)
    }
    
    func testProvisionItem_PublishesDomainEvent() {
        provisionIrrelevantItem()
        
        XCTAssert(publisher.lastPublishedEvent != nil)
    }
}
