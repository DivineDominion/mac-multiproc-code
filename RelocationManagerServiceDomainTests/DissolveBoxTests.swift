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
    
    let publisherDouble = MockDomainEventPublisher()
    
    let boxRepoDouble = TestBoxRepository()
    let itemRepoStub = NullItemRepository()
    let distributionStub = NullDistributeItem()
    
    lazy var service: DissolveBox = DissolveBox(boxRepository: self.boxRepoDouble, itemRepository: self.itemRepoStub, distributionService: self.distributionStub)
    
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisherDouble)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }
    
    // MARK: General assertion in both success/failure case
    
    func testDissolve_DelegatesToDistributionService() {
        let boxId = BoxId(3344)
        let box = TestBox(boxId: boxId)
        boxRepoDouble.availableBox = box
        
        service.dissolve(boxId)
        
        XCTAssertTrue(box.didDissolve)
        if box.didDissolve {
            if let redistributedWith = box.redistributedWith as? DistributeItem {
                if redistributedWith !== distributionStub {
                    XCTFail("wrong redistribution service used")
                }
            } else {
                XCTFail("wrong kind of redistribution service used")
            }
        }
    }
    
    func testDissolve_TestsEmptinessWithItemRepo() {
        let boxId = BoxId(909)
        let box = TestBox(boxId: boxId)
        boxRepoDouble.availableBox = box
        
        service.dissolve(boxId)
        
        XCTAssertTrue(box.didTestEmptiness)
        if box.didTestEmptiness {
            if let testedWith = box.emptinessTestedWith as? NullItemRepository {
                if testedWith !== itemRepoStub {
                    XCTFail("wrong item provider service used")
                }
            } else {
                XCTFail("wrong kind of item provider used")
            }
        }
    }
    
    
    // MARK: Success

    func testDissolve_WhenBoxIsEmpty_RemovesBox() {
        let box = TestBox().empty()
        boxRepoDouble.availableBox = box
        
        service.dissolve(box.boxId)
        
        XCTAssert(boxRepoDouble.didRemoveAvailableBox)
    }
    
    func testDissolve_WhenBoxIsEmpty_PublishedSuccessEvent() {
        let box = TestBox().empty()
        boxRepoDouble.availableBox = box
        
        service.dissolve(box.boxId)
        
        if let event = publisherDouble.lastPublishedEvent as? BoxRemoved {
            XCTAssertEqual(event.boxId, box.boxId)
        } else {
            XCTFail("should publish success event")
        }
    }
    
    
    // MARK: Failure
    
    func testDissolve_WhenBoxWasntEmptied_PublishesFailureEvent() {
        let box = TestBox().fill()

        service.dissolve(box.boxId)
        
        if let event = publisherDouble.lastPublishedEvent as? BoxRemovalFailed {
            XCTAssertEqual(event.boxId, box.boxId)
        } else {
            XCTFail("should publish failure event")
        }
    }
    
    func testDissolve_WhenBoxWasntEmptied_DoesntRemoveBox() {
        let box = TestBox().fill()
        
        service.dissolve(box.boxId)
        
        XCTAssert(boxRepoDouble.removedBoxId == nil)
    }

    
    // MARK: -
    // MARK: Test Doubles
    
    class TestBox: Box {
        convenience init() {
            self.init(boxId: BoxId(8765))
        }
        
        init(boxId: BoxId) {
            super.init(boxId: boxId, capacity: .Medium, title: "irrelevant")
        }
        
        private(set) var didDissolve = false
        private(set) var redistributedWith: RedistributesItems? = nil
        override func dissolve(redistributionService: RedistributesItems) {
            didDissolve = true
            redistributedWith = redistributionService
        }
        
        
        func empty() -> Box {
            isFull = false
            return self
        }
        
        func fill() -> Box {
            isFull = true
            return self
        }
        
        private(set) var didTestEmptiness = false
        var isFull = false
        private(set) var emptinessTestedWith: ProvidesBoxItems? = nil
        override func isEmpty(itemProvider: ProvidesBoxItems) -> Bool {
            emptinessTestedWith = itemProvider
            didTestEmptiness = true
            return !isFull
        }
    }
    
    class TestBoxRepository: NullBoxRepository {
        var availableBox: Box? = nil
        
        override func box(#boxId: BoxId) -> Box? {
            return availableBox
        }
        
        private(set)var removedBoxId: BoxId?
        override func removeBox(#boxId: BoxId) {
            removedBoxId = boxId
        }
        
        var didRemoveAvailableBox: Bool {
            return removedBoxId != nil && availableBox?.boxId == removedBoxId
        }
    }
}
