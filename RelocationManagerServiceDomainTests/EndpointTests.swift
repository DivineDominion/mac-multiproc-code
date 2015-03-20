//
//  EndpointTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 20/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManagerServiceDomain

class EndpointTests: XCTestCase {

    class TestManageBoxes: ManageBoxes {
        struct Order {
            let label: String
            let capacity: Int
        }
        
        var lastOrder: Order?
        override func orderBox(label: String, capacity: Int) {
            lastOrder = Order(label: label, capacity: capacity)
        }
        
        var lastRemoval: IntegerId?
        override func removeBox(boxIdentifier: IntegerId) {
            lastRemoval = boxIdentifier
        }
    }
    
    class TestManageItems: ManageItems {
        var lastDistributedTitle: String?
        override func distributeItem(title: String) {
            lastDistributedTitle = title
        }
        
        struct Removal {
            let itemIdentifier: IntegerId
            let boxIdentifier: IntegerId
        }
        
        var lastRemoval: Removal?
        override func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
            lastRemoval = Removal(itemIdentifier: itemIdentifier, boxIdentifier: boxIdentifier)
        }
    }
    
    let boxManagementDouble = TestManageBoxes()
    let itemManagementDouble = TestManageItems()
    
    lazy var endpoint: Endpoint = Endpoint(manageBoxes: self.boxManagementDouble, manageItems: self.itemManagementDouble)
    

    // MARK: Box Management
    
    func testOrderBox_DelegatesToBoxManager() {
        let label = "a label"
        let capacity = 456
        
        endpoint.orderBox(label, capacity: capacity)
        
        if let order = boxManagementDouble.lastOrder {
            XCTAssertEqual(order.label, label)
            XCTAssertEqual(order.capacity, capacity)
        } else {
            XCTFail("no box order delegated")
        }
    }

    func testRemoveBox_DelegatesToBoxManager() {
        let expectedIdentifier: IntegerId = 1235
        
        endpoint.removeBox(boxIdentifier: expectedIdentifier)
        
        if let identifier = boxManagementDouble.lastRemoval {
            XCTAssertEqual(identifier, expectedIdentifier)
        } else {
            XCTFail("no removal delegated")
        }
    }

    
    // MARK: Item Management
    
    func testDistributeItem_DelegatesToItemManager() {
        let title = "some title"
        
        endpoint.distributeItem(title)
        
        if let distributedTitle = itemManagementDouble.lastDistributedTitle {
            XCTAssertEqual(distributedTitle, title)
        } else {
            XCTFail("no item distributed")
        }
    }
    
    func testRemoveItem_DelegatestoItemManager() {
        let itemIdentifier: IntegerId = 558899
        let boxIdentifier: IntegerId = 91235
        
        endpoint.removeItem(itemIdentifier: itemIdentifier, fromBoxWithIdentifier: boxIdentifier)
        
        if let removal = itemManagementDouble.lastRemoval {
            XCTAssertEqual(removal.itemIdentifier, itemIdentifier)
            XCTAssertEqual(removal.boxIdentifier, boxIdentifier)
        } else {
            XCTFail("no removal delegated")
        }
    }

}
