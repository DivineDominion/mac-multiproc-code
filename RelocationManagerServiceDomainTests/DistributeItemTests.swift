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
    class TestBoxRepository: BoxRepository {
        func nextId() -> BoxId { return BoxId(0) }
        
        func nextItemId() -> ItemId { return ItemId(0) }
        
        func addBox(box: Box) { }
        func removeBox(#boxId: BoxId) { }
        
        func box(#boxId: BoxId) -> Box? { return nil }
        
        var boxesStub = [Box]()
        func boxes() -> [Box] {
            return boxesStub
        }
        
        func count() -> Int {
            return 0
        }
    }
    
    class TestProvisioningService: ProvisioningService {
        override func provisionBox(#capacity: BoxCapacity) { }
        
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
    lazy var distributeItem: DistributeItem = {
        DistributeItem(repository: self.repository, provisioningService: self.provisioningService)
    }()
    
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
    
    func testDistributeItem_WithOneEmptyBox_ProvisionsItem() {
        let box = emptyBox()
        repository.boxesStub = [box]
        let itemTitle = "the title"
        
        distributeItem.distribute(itemTitle: itemTitle)
        
        if let receivedTitle = provisioningService.provisionedItemTitle {
            XCTAssertEqual(provisioningService.provisionedItemTitle!, itemTitle)
        } else {
            XCTFail("no item provisioned")
        }
    }
    
    func testDistributeItem_WithOneFullBox_PublishesFailureDomainEvent() {
        repository.boxesStub = [fullBox()]
        
        distributeItem.distribute(itemTitle: "irrelevant")
        
        let maybeExpectedEvent = publisher.lastPublishedEvent as? BoxItemDistributionDidFail
        XCTAssert(maybeExpectedEvent != nil, "expected BoxItemDistributionDidFail event")
    }
    
    func testDistributeItem_WithOneFullBox_DoesntProvisionItem() {
        repository.boxesStub = [fullBox()]
        
        distributeItem.distribute(itemTitle: "irrelevant")
        
        XCTAssertFalse(provisioningService.didProvisionItem)
    }

    func testDistributeItem_WithOneFullAndOneEmptyBox_ProvisionsItem() {
        repository.boxesStub = [fullBox(), emptyBox()]
        
        distributeItem.distribute(itemTitle: "irrelevant")
        
        XCTAssertTrue(provisioningService.didProvisionItem)
    }
    
}
