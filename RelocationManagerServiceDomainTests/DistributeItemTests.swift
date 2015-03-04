//
//  DistributeItemTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 24/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class DistributeItemTests: XCTestCase {
    class TestBoxRepository: NullBoxRepository {
        var boxesStub = [Box]()
        override func boxes() -> [Box] {
            return boxesStub
        }
    }
    
    class TestProvisioningService: ProvisioningService {
        override func provisionBox(label: String, capacity: BoxCapacity) { }
        
        var provisionedItemTitle: String?
        var didProvisionItem = false
        override func provisionItem(title: String, inBox box: Box) {
            provisionedItemTitle = title
            didProvisionItem = true
        }
    }
    
    let publisher = MockDomainEventPublisher()
    
    let repository = TestBoxRepository()
    lazy var provisioningService: TestProvisioningService = {
        TestProvisioningService(repository: self.repository)
    }()
    
    let distributeItem = DistributeItem()
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }
    
    func emptyBox() -> Box {
        return Box(boxId: BoxId(0), capacity: .Medium, title: "irrelevant")
    }
    
    func fullBox() -> Box {
        let box = emptyBox()
        
        for index in 1...box.capacity.rawValue {
            box.addItem(Item(itemId: ItemId(1), title: "irrelevant item"))
        }
        
        return box
    }
    
    
    // MARK: Item Distribution
    
    func distribute(title: String) {
        distributeItem.distribute(itemTitle: title, provisioningService: provisioningService, boxRepository: repository)
    }
    
    func testDistributeItem_WithOneEmptyBox_ProvisionsItem() {
        let box = emptyBox()
        repository.boxesStub = [box]
        let itemTitle = "the title"
        
        distribute(itemTitle)
        
        if let receivedTitle = provisioningService.provisionedItemTitle {
            XCTAssertEqual(provisioningService.provisionedItemTitle!, itemTitle)
        } else {
            XCTFail("no item provisioned")
        }
    }
    
    func testDistributeItem_WithOneFullBox_PublishesFailureDomainEvent() {
        repository.boxesStub = [fullBox()]
        
        distribute("irrelevant")
        
        let maybeExpectedEvent = publisher.lastPublishedEvent as? BoxItemDistributionFailed
        XCTAssert(maybeExpectedEvent != nil, "expected BoxItemDistributionFailed event")
    }
    
    func testDistributeItem_WithOneFullBox_DoesntProvisionItem() {
        repository.boxesStub = [fullBox()]
        
        distribute("irrelevant")
        
        XCTAssertFalse(provisioningService.didProvisionItem)
    }

    func testDistributeItem_WithOneFullAndOneEmptyBox_ProvisionsItem() {
        repository.boxesStub = [fullBox(), emptyBox()]
        
        distribute("irrelevant")
        
        XCTAssertTrue(provisioningService.didProvisionItem)
    }
    
}
