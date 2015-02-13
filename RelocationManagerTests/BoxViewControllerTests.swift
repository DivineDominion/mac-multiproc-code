//
//  BoxViewControllerTests.swift
//  RelocationManager
//
//  Created by Christian Tietze on 13/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa
import XCTest

import RelocationManager

class TestBoxNode: BoxNode {
    convenience init(title: String, boxId: BoxId) {
        self.init(boxId: boxId)
        
        self.title = title
        capacity = 1234
        children = []
        isLeaf = false
    }
    
    convenience init(title: String) {
        self.init(title: title, boxId: BoxId(0))
    }
    
    convenience init() {
        self.init(title: "title")
    }
}

class BoxViewControllerTests: XCTestCase {
    var viewController: BoxViewController!
//    var testEventHandler: EventHandlerStub! = EventHandlerStub()
    
    override func setUp() {
        super.setUp()
        
        let windowController = BoxManagementWindowController()
        windowController.loadWindow()
        viewController = windowController.boxViewController
//        viewController.eventHandler = testEventHandler
    }

    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: Nib Setup
    
    func testView_IsLoaded() {
        XCTAssertNotNil(viewController.view, "view should be set in Nib")
        XCTAssertEqual(viewController.view.className, "NSOutlineView", "view should be outline view")
        XCTAssertEqual(viewController.view, viewController.outlineView, "tableView should be alternative to view")
    }
    
    func testOutlineViewColumns_NamedProperly() {
        let outlineView = viewController.outlineView
        
        XCTAssertNotNil(outlineView.tableColumnWithIdentifier(kColumnNameLabel))
        XCTAssertNotNil(outlineView.tableColumnWithIdentifier(kColumnNameCapacity))
    }
    
    func testItemsController_IsConnected() {
        XCTAssertNotNil(viewController.itemsController)
    }
    
    func testItemsController_PreservesSelection() {
        XCTAssertTrue(viewController.itemsController.preservesSelection)
    }
    
    func testItemsController_CocoaBindings() {
        let controller = viewController.itemsController
        let outlineView = viewController.outlineView
        let labelColumn = outlineView.tableColumnWithIdentifier(kColumnNameLabel)
        let capacityColumn = outlineView.tableColumnWithIdentifier(kColumnNameCapacity)
        
        XCTAssertTrue(hasBinding(controller, binding: NSSortDescriptorsBinding, to: viewController, throughKeyPath: "self.itemsSortDescriptors"))
        XCTAssertTrue(hasBinding(outlineView, binding: NSContentBinding, to: controller, throughKeyPath: "arrangedObjects"))
        
        XCTAssertTrue(hasBinding(labelColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.title"))
        XCTAssertTrue(hasBinding(capacityColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.capacity"))
    }

    func testOrderBoxButton_IsConnected() {
        XCTAssertNotNil(viewController.orderBoxButton)
    }
    
    func testOrderBoxButton_IsWiredToAction() {
        XCTAssertEqual(viewController.orderBoxButton.action, Selector("orderBox:"))
    }
    
    func testAddItemButton_IsConnected() {
        XCTAssertNotNil(viewController.addItemButton)
    }
    
    func testAddItemButton_IsWiredToAction() {
        XCTAssertEqual(viewController.addItemButton.action, Selector("addItem:"))
    }
    
    func testAddItemButton_CocoaBindings() {
        XCTAssertTrue(hasBinding(viewController.addItemButton, binding: NSEnabledBinding, to: viewController.itemsController, throughKeyPath: "canAddChild"), "enable button in virtue of itemsController having parent nodes")
    }
    
    func testRemoveButton_IsConnected() {
        XCTAssertNotNil(viewController.removeSelectionButton)
    }
    
    func testRemoveButton_IsWiredToAction() {
        XCTAssertEqual(viewController.removeSelectionButton.action, Selector("removeSelectedObject:"))
    }
    
    func testRemoveButton_CocoaBindings() {
        XCTAssertTrue(hasBinding(viewController.removeSelectionButton, binding: NSEnabledBinding, to: viewController.itemsController, throughKeyPath: "selectionIndexPath", transformingWith: "NSIsNotNil"), "enable button in virtue of itemsController selection != nil")
    }
    
    func testItemRowView_TitleCell_SetUpProperly() {
        viewController.itemsController.addObject(TestBoxNode())
        
        let titleCellView: NSTableCellView = viewController.outlineView.viewAtColumn(0, row: 0, makeIfNecessary: true) as NSTableCellView
        let titleTextField = titleCellView.textField!
        XCTAssertTrue(titleTextField.editable)
        XCTAssertTrue(hasBinding(titleTextField, binding: NSValueBinding, to: titleCellView, throughKeyPath: "objectValue.title", transformingWith: "NonNilStringValueTransformer"))
    }

    func testItemRowView_CapacityCell_SetUpProperly() {
        viewController.itemsController.addObject(TestBoxNode())
        
        let capacityCellView: NSTableCellView = viewController.outlineView.viewAtColumn(1, row: 0, makeIfNecessary: true) as NSTableCellView
        let capacityTextField = capacityCellView.textField!
        XCTAssertFalse(capacityTextField.editable)
        XCTAssertTrue(hasBinding(capacityTextField, binding: NSValueBinding, to: capacityCellView, throughKeyPath: "objectValue.capacity"))
    }
}
