//
//  ManageBoxesAndItemsTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 03/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class ManageBoxesAndItemsTests: XCTestCase {
    class TestProvisioningService: ProvisioningService {
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
    
    class TestDistributeItem: DistributeItem {
        var didDistributeItem = false
        var itemTitle: String?
        override func distribute(itemTitle title: String, provisioningService: ProvisioningService, boxRepository repository: BoxRepository) {
            
            self.itemTitle = title
            didDistributeItem = true
        }
    }
    
    lazy var service: ManageBoxesAndItems = {
        let service = ManageBoxesAndItems()
        service.repository = self.repository
        service.provisioningService = self.provisioningService
        service.distributionService = self.distributionService
        return service
    }()
    
    let distributionService = TestDistributeItem()
    let repository = NullBoxRepository()
    lazy var provisioningService: TestProvisioningService = {
        TestProvisioningService(repository: self.repository)
    }()
    
    // MARK: Provision Box
    
    func testProvisionBox_WithValidCapacity_ProvisionsBox() {
        let title = "The Box"
        let capacity = BoxCapacity.Medium.rawValue
        
        service.provisionBox(title, capacity: capacity)
        
        XCTAssertTrue(provisioningService.didProvisionBox)
        if provisioningService.didProvisionBox {
            XCTAssertEqual(provisioningService.provisionedBoxTitle!, title)
            XCTAssertEqual(provisioningService.provisionedBoxCapacity!, capacity)
        }
    }
    
    func testProvisionBox_WithInvalidCapacity_DoesNotProvisionBox() {
        service.provisionBox("irrelevant", capacity: 1000)
        
        XCTAssertFalse(provisioningService.didProvisionBox)
    }

    
    // MARK: Provision Item
    
    func testProvisionItem_DelegatesToDistributionService() {
        let itemTitle = "the name"
        
        service.provisionItem(itemTitle)
        
        XCTAssertTrue(distributionService.didDistributeItem)
        if distributionService.didDistributeItem {
            XCTAssertEqual(distributionService.itemTitle!, itemTitle)
        }
    }
}
