//
//  DissolveBoxTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 12/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

/// Integration Tests
class DissolveBoxTests: XCTestCase {
    class TestBoxRepository: NullBoxRepository {
        var removedBoxId: BoxId?
        override func removeBox(#boxId: BoxId) {
            removedBoxId = boxId
        }
    }
    
    class TestDistributeItem: NullDistributeItem {
        var redistributedBox: Box?
        override func redistributeItems(box: Box) {
            redistributedBox = box
        }
    }
    
    let boxFactory = TestBoxFactory()
    let publisher = MockDomainEventPublisher()
    
    let boxRepository = TestBoxRepository()
    lazy var itemRepository: ItemRepository = self.boxFactory.itemRepository
    let distributionService = TestDistributeItem()
    
    lazy var service: DissolveBox = DissolveBox(distributionService: self.distributionService, boxRepository: self.boxRepository, itemRepository: self.itemRepository)
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }
    
    func testDissolve_DelegatesToDistributionService() {
        let box = boxFactory.fullBox()
        
        service.dissolve(box)
        
        XCTAssert(distributionService.redistributedBox == box)
    }

    func testDissolve_WhenBoxIsEmpty_RemovesBoxLocked() {
        let box = boxFactory.emptyBox()
        
        service.dissolve(box)
        
        XCTAssertTrue(box.locked)
        XCTAssert(boxRepository.removedBoxId == box.boxId)
    }
    
    func testDissolve_WhenBoxIsEmpty_PublishedSuccessEvent() {
        let box = boxFactory.emptyBox()
        
        service.dissolve(box)
        
        let event = publisher.lastPublishedEvent as? BoxRemoved
        XCTAssert(event != nil, "should publish success event")
    }
    
    func testDissolve_WhenBoxWasntEmptied_UnlocksBox() {
        let box = boxFactory.fullBox()
        
        service.dissolve(box)
        
        XCTAssertFalse(box.locked)
    }
    
    func testDissolve_WhenBoxWasntEmptied_PublishesFailureEvent() {
        let box = boxFactory.fullBox()

        service.dissolve(box)
        
        let event = publisher.lastPublishedEvent as? BoxRemovalFailed
        XCTAssert(event != nil, "should publish failure event")
    }
    
    func testDissolve_WhenBoxWasntEmptied_DoesntRemoveBox() {
        let box = boxFactory.fullBox()
        
        service.dissolve(box)
        
        XCTAssert(boxRepository.removedBoxId == nil)
    }

}
