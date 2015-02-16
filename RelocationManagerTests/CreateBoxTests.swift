//
//  CreateBoxTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 16/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManager

class BoxOrderingServiceStub: ManagesBoxesAndItems {
    var label: String = ""
    var capacity: Int = 0
    
    func provisionBox(label: String, capacity: Int) {
        self.label = label
        self.capacity = capacity
    }
    
    func provisionItem(name: String, inBoxWithIdentifier boxIdentifier: IntegerId) { }
    func removeBox(boxIdentifier: IntegerId) { }
    func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) { }
}

class TestModalizer: RunModal {
    var didRunModal = false
    override func runModalForWindow(theWindow: NSWindow) {
        didRunModal = true
    }
    
    var didStopModal = false
    override func stopModal() {
        didStopModal = true
    }
}

class CreateBoxTests: XCTestCase {

    var orderingService: BoxOrderingServiceStub! = BoxOrderingServiceStub()
    var modalizer: TestModalizer! = TestModalizer()
    
    lazy var controller: CreateBox! = {
        let createBox = CreateBox(orderService: self.orderingService)
        createBox.modalizer = self.modalizer
        
        return createBox
    }()
    
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testShowDialog_LoadsWindow() {
        controller.showDialog()
        
        XCTAssertNotNil(controller.windowController)
        XCTAssert(controller.windowController.window!.visible)
    }
    
    func testShowDialog_RunsModal() {
        controller.showDialog()
        
        XCTAssert(modalizer.didRunModal)
    }

    func testOrder_ProvisionsBox() {
        let boxOrder = BoxOrder(label: "the label", capacity: 123)
        
        controller.order(boxOrder)
        
        XCTAssertEqual(orderingService.label, boxOrder.label)
        XCTAssertEqual(orderingService.capacity, boxOrder.capacity)
    }
    
    func testCancel_StopsWindowModal() {
        controller.cancel()
        
        XCTAssertTrue(modalizer.didStopModal)
    }
}
