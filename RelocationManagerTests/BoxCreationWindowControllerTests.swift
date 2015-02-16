//
//  BoxCreationWindowControllerTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 16/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManager

class HandlesBoxCreationEventsStub: HandlesBoxCreationEvents {
    var orderClosure: (BoxOrder)->() = { _ in }
    func order(boxOrder: BoxOrder) {
        orderClosure(boxOrder)
    }
    
    var cancelClosure: ()->() = {}
    func cancel() {
        cancelClosure()
    }
}

class BoxCreationWindowControllerTests: XCTestCase {
    var windowController: BoxCreationWindowController!
    var eventHandler = HandlesBoxCreationEventsStub()
    
    override func setUp() {
        super.setUp()
    
        windowController = BoxCreationWindowController()
        windowController.loadWindow()
        windowController.eventHandler = eventHandler
    }
    
    override func tearDown() {
        super.tearDown()
    }

    
    // MARK: -
    // MARK: Nib Setup
    
    func testWindow_IsConnected() {
        XCTAssertNotNil(windowController.window)
    }
    
    func testWindow_IsDialog() {
        XCTAssertEqual(windowController.window!.level, kCGModalPanelWindowLevelKey)
    }
    
    func testCancelButton_IsConnected() {
        XCTAssertNotNil(windowController.cancelButton)
    }

    func testOrderButton_IsConnected() {
        XCTAssertNotNil(windowController.orderButton)
    }
    
    func testCapacity_IsConnected() {
        XCTAssertNotNil(windowController.capacityComboBox)
    }
    
    func testCapacity_Shows10() {
        XCTAssertEqual(windowController.capacityComboBox.stringValue, "10")
    }
    
    func testBoxLabel_IsConnected() {
        XCTAssertNotNil(windowController.boxLabelTextField)
    }
    
    // MARK: -
    // MARK: Ordering
    
    func testOrdering_CreatesBoxOrder() {
        var boxOrder: BoxOrder?
        eventHandler.orderClosure = { order in
            boxOrder = order
        }
        
        windowController.capacityComboBox.stringValue = "30"
        windowController.order(self)
        
        XCTAssert(boxOrder != nil)
        if let boxOrder = boxOrder {
            XCTAssertEqual(boxOrder.label, "New Box")
            XCTAssertEqual(boxOrder.capacity, 30)
        }
    }
    
    func testOrdering_NotifiesEventHandler() {
        var didReceiveOrder = false
        eventHandler.orderClosure = { _ in
            didReceiveOrder = true
        }
        
        windowController.order(self)
        
        XCTAssertTrue(didReceiveOrder)
    }
    
    // MARK: Cancelling
    
    func testCancelling_NotifiesEventHandler() {
        var didReceiveCancel = false
        eventHandler.cancelClosure = {
            didReceiveCancel = true
        }
        
        windowController.cancel(self)
        
        XCTAssertTrue(didReceiveCancel)
    }
    
    
    // MARK: -
    // MARK: Window Events
    
    func testClosing_Cancels() {
        var didReceiveCancel = false
        eventHandler.cancelClosure = {
            didReceiveCancel = true
        }
        
        windowController.windowWillClose(irrelevantNotification)
        
        XCTAssertTrue(didReceiveCancel)
    }
    
}
