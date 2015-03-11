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
    
    let boxFactory = TestBoxFactory()
    let boxRepository = TestBoxRepository()
    lazy var itemRepository: ItemRepository = self.boxFactory.itemRepository
    
    let publisher = MockDomainEventPublisher()
    
    lazy var provisioningService: TestProvisioningService = TestProvisioningService(boxRepository: NullBoxRepository(), itemRepository: NullItemRepository())
    lazy var distributeItem: DistributeItem = DistributeItem(boxRepository: self.boxRepository, itemRepository: self.itemRepository, provisioningService: self.provisioningService)
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }
    
    func emptyBox() -> Box {
        return boxFactory.emptyBox()
    }
    
    func fullBox() -> Box {
        return boxFactory.fullBox()
    }
    
    
    // MARK: Item Distribution
    
    func distribute(title: String) {
        distributeItem.distribute(itemTitle: title)
    }
    
    func testDistributeItem_WithOneEmptyBox_ProvisionsItem() {
        boxRepository.boxesStub = [emptyBox()]
        let itemTitle = "the title"
        
        distribute(itemTitle)
        
        if let receivedTitle = provisioningService.provisionedItemTitle {
            XCTAssertTrue(provisioningService.didProvisionItem)
            XCTAssertEqual(provisioningService.provisionedItemTitle!, itemTitle)
        } else {
            XCTFail("no item provisioned")
        }
    }
    
    func testDistributeItem_WithOneFullBox_PublishesFailureDomainEvent() {
        boxRepository.boxesStub = [fullBox()]
        
        distribute("irrelevant")
        
        let maybeExpectedEvent = publisher.lastPublishedEvent as? BoxItemDistributionFailed
        XCTAssert(maybeExpectedEvent != nil, "expected BoxItemDistributionFailed event")
    }
    
    func testDistributeItem_WithOneFullBox_DoesntProvisionItem() {
        boxRepository.boxesStub = [fullBox()]
        
        distribute("irrelevant")
        
        XCTAssertFalse(provisioningService.didProvisionItem)
    }

    func testDistributeItem_WithOneFullAndOneEmptyBox_ProvisionsItem() {
        boxRepository.boxesStub = [fullBox(), emptyBox()]
        
        distribute("irrelevant")
        
        XCTAssertTrue(provisioningService.didProvisionItem)
    }
    
}
