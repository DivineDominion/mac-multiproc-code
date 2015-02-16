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

class TestItemNode: ItemNode {
    convenience init(title: String, itemId: ItemId) {
        self.init(itemId: itemId)
        
        self.title = title
        capacity = 666
        children = []
        isLeaf = true
    }
    
    convenience init(title: String) {
        self.init(title: title, itemId: ItemId(0))
    }
    
    convenience init() {
        self.init(title: "title")
    }
}

class HandlesItemListEventsStub: HandlesItemListEvents {
    var createBoxClosure: ()->() = {}
    func createBox() {
        createBoxClosure()
    }
    
    var createItemClosure: ()->() = {}
    func createItem() {
        createItemClosure()
    }
    
    func changeBoxTitle(boxId: BoxId, title: String) {
        // no op
    }
    
    func changeItemTitle(itemId: ItemId, title: String, inBox boxId: BoxId) {
        // no op
    }
    
    var removeItemClosure: (itemId: ItemId, boxId: BoxId) -> () = { _, _ in }
    func removeItem(itemId: ItemId, fromBox boxId: BoxId) {
        removeItemClosure(itemId: itemId, boxId: boxId)
    }
    
    var removeBoxClosure: (boxId: BoxId) -> () = { _ in }
    func removeBox(boxId: BoxId) {
        removeBoxClosure(boxId: boxId)
    }
}

class BoxViewControllerTests: XCTestCase {
    var viewController: BoxViewController!
    var testEventHandler: HandlesItemListEventsStub! = HandlesItemListEventsStub()
    
    override func setUp() {
        super.setUp()
        
        let windowController = BoxManagementWindowController()
        windowController.loadWindow()
        viewController = windowController.boxViewController
        viewController.eventHandler = testEventHandler
    }

    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Helpers
    
    func boxNodes() -> [NSTreeNode] {
        return viewController.treeController.arrangedObjects.childNodes!! as [NSTreeNode]
    }
    
    func boxNodeCount() -> Int {
        return boxNodes().count
    }
    
    func boxAtIndex(index: Int) -> NSTreeNode {
        return boxNodes()[index]
    }
    
    func itemTreeNode(atBoxIndex boxIndex: Int, itemIndex: Int) -> NSTreeNode {
        let boxNode: NSTreeNode = boxAtIndex(boxIndex)
        return boxNode.childNodes![itemIndex] as NSTreeNode
    }
    
    func boxDataStub() -> BoxData {
        return BoxData(boxId: BoxId(0), title: "irrelevant", itemData: [])
    }
    
    func itemDataStub() -> ItemData {
        return itemDataStub(parentBoxId: BoxId(666))
    }
    
    func itemDataStub(parentBoxId boxId: BoxId) -> ItemData {
        return ItemData(itemId: ItemId(0), title: "irrelevant", boxId: boxId)
    }
    

    // MARK: -
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
        XCTAssertNotNil(viewController.treeController)
    }
    
    func testItemsController_PreservesSelection() {
        XCTAssertTrue(viewController.treeController.preservesSelection)
    }
    
    func testItemsController_CocoaBindings() {
        let controller = viewController.treeController
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
        XCTAssertTrue(hasBinding(viewController.addItemButton, binding: NSEnabledBinding, to: viewController.treeController, throughKeyPath: "canAddChild"), "enable button in virtue of treeController having parent nodes")
    }
    
    func testRemoveButton_IsConnected() {
        XCTAssertNotNil(viewController.removeSelectionButton)
    }
    
    func testRemoveButton_IsWiredToAction() {
        XCTAssertEqual(viewController.removeSelectionButton.action, Selector("removeSelectedObject:"))
    }
    
    func testRemoveButton_CocoaBindings() {
        XCTAssertTrue(hasBinding(viewController.removeSelectionButton, binding: NSEnabledBinding, to: viewController.treeController, throughKeyPath: "selectionIndexPath", transformingWith: "NSIsNotNil"), "enable button in virtue of treeController selection != nil")
    }
    
    func testItemRowView_TitleCell_SetUpProperly() {
        viewController.treeController.addObject(TestBoxNode())
        
        let titleCellView: NSTableCellView = viewController.outlineView.viewAtColumn(0, row: 0, makeIfNecessary: true) as NSTableCellView
        let titleTextField = titleCellView.textField!
        XCTAssertTrue(titleTextField.editable)
        XCTAssertTrue(hasBinding(titleTextField, binding: NSValueBinding, to: titleCellView, throughKeyPath: "objectValue.title", transformingWith: "NonNilStringValueTransformer"))
    }

    func testItemRowView_CapacityCell_SetUpProperly() {
        viewController.treeController.addObject(TestBoxNode())
        
        let capacityCellView: NSTableCellView = viewController.outlineView.viewAtColumn(1, row: 0, makeIfNecessary: true) as NSTableCellView
        let capacityTextField = capacityCellView.textField!
        XCTAssertFalse(capacityTextField.editable)
        XCTAssertTrue(hasBinding(capacityTextField, binding: NSValueBinding, to: capacityCellView, throughKeyPath: "objectValue.capacity"))
    }
    
    
    // MARK: -
    // MARK: Ordering Boxes
    
    func testOrderBox_WithEventHandler_CreatesBox() {
        var didCreateBox = false
        testEventHandler.createBoxClosure = {
            didCreateBox = true
        }
        
        viewController.orderBox(self)
        
        XCTAssertTrue(didCreateBox)
    }
    
    // MARK: Consuming Boxes
    
    func testInitially_TreeIsEmpty() {
        XCTAssertEqual(boxNodeCount(), 0, "start with empty tree")
    }
    
    func testInitially_AddItemButtonIsDisabled() {
        XCTAssertFalse(viewController.addItemButton.enabled, "disable item button without boxes")
    }
    
    func testConsumeBox_WithEmptyList_AddsNode() {
        viewController.consume(boxDataStub())
        
        XCTAssertEqual(boxNodeCount(), 1, "adds box to tree")
    }
    
    func testConsumeBox_WithEmptyList_EnablesAddItemButton() {
        viewController.consume(boxDataStub())
        
        XCTAssertTrue(viewController.addItemButton.enabled, "enable item button by adding boxes")
    }
    
    func testConsumeBox_WithExistingBox_OrdersThemByTitle() {
        // Given
        let bottomItem = TestBoxNode(title: "ZZZ Should be at the bottom")
        viewController.treeController.addObject(bottomItem)
        
        let existingNode: NSObject = boxAtIndex(0)
        
        // When
        viewController.consume(boxDataStub())
        
        // Then
        XCTAssertEqual(boxNodeCount(), 2, "add node to existing one")
        let lastNode: NSObject = boxAtIndex(1)
        XCTAssertEqual(existingNode, lastNode, "new node should be put before existing one")
    }
    
    func testAddBox_Twice_SelectsSecondBox() {
        let treeController = viewController.treeController
        treeController.addObject(TestBoxNode(title: "first"))
        treeController.addObject(TestBoxNode(title: "second"))
        
        XCTAssertTrue(treeController.selectedNodes.count > 0, "should auto-select")
        let selectedNode: NSTreeNode = treeController.selectedNodes[0] as NSTreeNode
        let item: TreeNode = selectedNode.representedObject as TreeNode
        XCTAssertEqual(item.title, "second", "select latest insertion")
    }
    
    // MARK: -
    // MARK: Adding Items
    
    func addingItemDidAddItem() -> Bool {
        var didAddItem = false
        testEventHandler.createItemClosure = {
            didAddItem = true
        }
        
        viewController.addItem(self)
        
        return didAddItem
    }
    
    func testAddingItem_WithoutBoxes_DoesntAddItem() {
        XCTAssertFalse(addingItemDidAddItem())
    }
    
    func testAddingItem_WithBoxes_AddsItem() {
        // Pre-populate
        viewController.treeController.addObject(TestBoxNode(title: "first", boxId: BoxId(1)))

        XCTAssertTrue(addingItemDidAddItem())
    }
    
    // MARK: Consuming Items
    
    func testConsumeItem_WithoutBoxes_DoesNothing() {
        viewController.consume(itemDataStub())
        
        XCTAssertEqual(boxNodeCount(), 0, "don't add boxes or anything")
    }
    
    func testConsumeItem_WithSelectedBox_InsertsItemBelowSelectedBox() {
        // Pre-populate
        let treeController = viewController.treeController
        treeController.addObject(TestBoxNode(title: "first", boxId: BoxId(1)))
        treeController.addObject(TestBoxNode(title: "second", boxId: BoxId(2)))
        
        // Select first node
        let selectionIndexPath = NSIndexPath(index: 0)
        treeController.setSelectionIndexPath(selectionIndexPath)
        let selectedBox = (treeController.selectedNodes[0] as NSTreeNode).representedObject as TreeNode
        XCTAssertEqual(selectedBox.children.count, 0, "box starts empty")
        
        viewController.consume(itemDataStub(parentBoxId: BoxId(1)))
        
        // Then
        if selectedBox.children.count > 0 {
            XCTAssert(selectedBox.children[0].isLeaf)
        } else {
            XCTFail("box contains no child")
        }
    }
    
    
    // MARK: -
    // MARK: Removing Boxes
    
    func setUpFirstBox() -> BoxNode {
        let boxNode = TestBoxNode(title: "the box")
        
        let treeController = viewController.treeController
        treeController.addObject(boxNode)
        treeController.setSelectionIndexPath(NSIndexPath(index: 0))
        
        XCTAssertEqual(boxNodeCount(), 1)
        
        return boxNode
    }

    func testRemoveBox_DoesntRemoveNode() {
        setUpFirstBox()
        let boxCountBefore = boxNodeCount()
        
        viewController.removeSelectedObject(self)
        
        XCTAssertEqual(boxNodeCount(), boxCountBefore)
    }

    func testRemoveBox_OrdersBoxRemoval() {
        let existingBoxNode = setUpFirstBox()
        
        var didRemoveBox = false
        testEventHandler.removeBoxClosure = { boxId in
            didRemoveBox = true
            
            XCTAssertEqual(boxId, existingBoxNode.boxId)
        }

        viewController.removeSelectedObject(self)
        
        XCTAssertTrue(didRemoveBox)
    }
    

    // MARK: Removing Items
    
    func setUpFirstBoxWithItem() -> TestItemNode {
        let itemNode = TestItemNode(title: "the item")
        
        let treeController = viewController.treeController
        let rootNode = TestBoxNode(title: "the box")
        rootNode.children = [itemNode]
        treeController.addObject(rootNode)
        treeController.setSelectionIndexPath(NSIndexPath(index: 0).indexPathByAddingIndex(0))
        XCTAssertEqual(boxNodes().first!.childNodes!.count, 1)
        
        return itemNode
    }
    
    func testRemoveItem_OrdersItemRemoval() {
        let existingItemNode = setUpFirstBoxWithItem()
        
        var didRemoveItem = false
        testEventHandler.removeItemClosure = { itemId, _ in
            didRemoveItem = true
            
            XCTAssertEqual(itemId, existingItemNode.itemId)
        }
        
        viewController.removeSelectedObject(self)
        
        XCTAssertTrue(didRemoveItem)
    }

    func testRemoveItem_DoesntRemoveNode() {
        setUpFirstBox()
        let itemCount: () -> Int = { return self.boxNodes().first!.childNodes!.count }
        let boxCountBefore = boxNodeCount()
        let itemCountBefore = itemCount()
        
        viewController.removeSelectedObject(self)
        
        XCTAssertEqual(boxNodeCount(), boxCountBefore)
        XCTAssertEqual(itemCount(), itemCountBefore)
    }
    
    // MARK: -
    // MARK: Displaying Box Data
    
    func testDisplayData_Once_PopulatesTree() {
        let itemId = ItemId(444)
        let itemData = ItemData(itemId: itemId, title: "irrelevant item title")
        let boxId = BoxId(1122)
        let boxData = BoxData(boxId: boxId, title: "irrelevant box title", itemData: [itemData])
        
        viewController.displayBoxData([boxData])
        
        XCTAssertEqual(boxNodeCount(), 1)
        let soleBoxTreeNode = boxAtIndex(0)
        let boxNode = soleBoxTreeNode.representedObject as BoxNode
        XCTAssertEqual(boxNode.boxId, boxId)
        
        let itemNodes = soleBoxTreeNode.childNodes! as [NSTreeNode]
        XCTAssertEqual(itemNodes.count, 1)
        if let soleItemTreeNode = itemNodes.first {
            let itemNode = soleItemTreeNode.representedObject as ItemNode
            XCTAssertEqual(itemNode.itemId, itemId)
        }
    }
    
    func testDisplayData_Twice_ReplacedNodes() {
        let itemId = ItemId(444)
        let itemData = ItemData(itemId: itemId, title: "irrelevant item title")
        let boxId = BoxId(1122)
        let boxData = BoxData(boxId: boxId, title: "irrelevant box title", itemData: [itemData])
        
        viewController.displayBoxData([boxData])
        viewController.displayBoxData([boxData])
        
        XCTAssertEqual(boxNodeCount(), 1)
        XCTAssertEqual(boxAtIndex(0).childNodes!.count, 1)
    }
}
