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
    class TestBoxRepository: BoxRepository {
        func nextId() -> BoxId {
            return BoxId(0)
        }
        
        func nextItemId() -> ItemId {
            return ItemId(0)
        }
        
        func addBox(box: Box) { }
        func removeBox(#boxId: BoxId) { }
        
        func box(#boxId: BoxId) -> Box? {
            return nil
        }
        
        func boxes() -> [Box] {
            return []
        }
        
        func count() -> Int {
            return 0
        }
    }
    
    let provisioningService = ProvisioningService(repository: TestBoxRepository())
    let publisher = MockDomainEventPublisher()
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.setSharedInstance(publisher)
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }

    func testProvisionBox_PublishesDomainEvent() {
        provisioningService.provisionBox("irrelevant", capacity: .Small)
        
        XCTAssert(publisher.lastPublishedEvent != nil)
    }

}
