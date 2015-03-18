//
//  ManageBoxesTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class ManageBoxesTests: XCTestCase {
    
    let registry = TestDomainRegistry()
    let provisioningDouble = TestProvisioningService(boxRepository: NullBoxRepository(), itemRepository: NullItemRepository())
    let dissolvingDouble = TestDissolveBox()
    
    let service = ManageBoxes()
    
    
    override func setUp() {
        super.setUp()

        NullServiceLocator.registerAsSharedInstance()
        
        registry.testProvisioningService = provisioningDouble
        registry.testDissolveBox = dissolvingDouble
        DomainRegistry.setSharedInstance(registry)
    }
    
    override func tearDown() {
        DomainRegistry.resetSharedInstance()
        NullServiceLocator.resetSharedInstance()
        
        super.tearDown()
    }
    
    
    // MARK: Order Box
    
    func testOrderBox_WithValidCapacity_ProvisionsBox() {
        let title = "The Box"
        let capacity = BoxCapacity.Medium.rawValue
        
        service.orderBox(title, capacity: capacity)
        
        XCTAssertTrue(provisioningDouble.didProvisionBox)
        if provisioningDouble.didProvisionBox {
            XCTAssertEqual(provisioningDouble.provisionedBoxTitle!, title)
            XCTAssertEqual(provisioningDouble.provisionedBoxCapacity!, capacity)
        }
    }
    
    func testOrderBox_WithInvalidCapacity_DoesNotProvisionBox() {
        service.orderBox("irrelevant", capacity: 1000)
        
        XCTAssertFalse(provisioningDouble.didProvisionBox)
    }
    
    
    // MARK: Remove Box
    
    func testRemoveBox_DelegatesToDissolvingService() {
        service.removeBox(1234)
        
        XCTAssert(dissolvingDouble.dissolvedBox == BoxId(1234))
    }
    
    
    // MARK: - 
    // MARK: Test Doubles
    
    class TestDissolveBox: NullDissolveBox {
        init() {
            super.init(boxRepository: NullBoxRepository(), itemRepository: NullItemRepository(), distributionService: NullDistributeItem())
        }
        
        private(set) var dissolvedBox: BoxId? = nil
        override func dissolve(boxId: BoxId) {
            dissolvedBox = boxId
        }
    }
    
    
    class TestProvisioningService: NullProvisioningService {
        override func provisionItem(title: String, inBox box: Box) { }
        
        var provisionedBoxTitle: String?
        var provisionedBoxCapacity: Int?
        var didProvisionBox = false
        override func provisionBox(title: String, capacity: BoxCapacity) {
            provisionedBoxTitle = title
            provisionedBoxCapacity = capacity.rawValue
            didProvisionBox = true
        }
    }
}
