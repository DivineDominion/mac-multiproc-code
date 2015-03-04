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
    lazy var service: ManageBoxes = {
        let service = ManageBoxes()
        service.repository = self.repository
        service.provisioningService = self.provisioningService
        return service
    }()
    
    let repository = NullBoxRepository()
    lazy var provisioningService: TestProvisioningService = {
        TestProvisioningService(repository: self.repository)
    }()
    
    
    // MARK: Provision Box
    
    func testProvisionBox_WithValidCapacity_ProvisionsBox() {
        let title = "The Box"
        let capacity = BoxCapacity.Medium.rawValue
        
        service.orderBox(title, capacity: capacity)
        
        XCTAssertTrue(provisioningService.didProvisionBox)
        if provisioningService.didProvisionBox {
            XCTAssertEqual(provisioningService.provisionedBoxTitle!, title)
            XCTAssertEqual(provisioningService.provisionedBoxCapacity!, capacity)
        }
    }
    
    func testProvisionBox_WithInvalidCapacity_DoesNotProvisionBox() {
        service.orderBox("irrelevant", capacity: 1000)
        
        XCTAssertFalse(provisioningService.didProvisionBox)
    }
}
