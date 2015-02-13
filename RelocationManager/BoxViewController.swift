//
//  BoxViewController.swift
//  RelocationManager
//
//  Created by Christian Tietze on 10/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa

public let kColumnNameLabel = "Label"
public let kColumnNameCapacity = "Capacity"

public class BoxViewController: NSViewController, NSOutlineViewDelegate, HandlesItemListChanges, ConsumesBoxAndItem {
    
    public weak var eventHandler: HandlesItemListEvents!
    
    // MARK: -
    // MARK: Outline
    
    public var outlineView: NSOutlineView {
        return self.view as NSOutlineView
    }
    
    @IBOutlet public weak var treeController: NSTreeController!
    
    var itemsSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: "caseInsensitiveCompare:")
        
        return [sortByTitle]
    }
    
    func orderTree() {
        treeController.rearrangeObjects()
    }
    
    func nodeCount() -> Int {
        return treeController.arrangedObjects.childNodes!!.count
    }
    
    func hasSelection() -> Bool {
        return treeController.selectedObjects.count > 0
    }
    
    func hasBoxes() -> Bool {
        return nodeCount() > 0
    }
    
    
    // MARK: Change node titles
    
    public func treeNodeDidChange(treeNode: TreeNode, title: String) {
        if title.isEmpty {
            changeNodeTitleToPlaceholderValue(treeNode)
        } else {
            broadcastTitleChange(treeNode)
            orderTree()
        }
    }
    
    func changeNodeTitleToPlaceholderValue(treeNode: TreeNode) {
        // Don't execute in didSet callback or KVO won't work
        dispatch_async_main {
            if treeNode is BoxNode {
                treeNode.title = BoxNode.defaultTitle
            } else if treeNode is ItemNode {
                treeNode.title = ItemNode.defaultTitle
            }
        }
    }
    
    func broadcastTitleChange(treeNode: TreeNode) {
        if let boxNode = treeNode as? BoxNode {
            eventHandler.changeBoxTitle(boxNode.boxId, title: boxNode.title)
        } else if let itemNode = treeNode as? ItemNode {
            if let boxNode = itemNode.parentBoxNode(inArray: boxNodes()) {
                eventHandler.changeItemTitle(itemNode.itemId, title: itemNode.title, inBox: boxNode.boxId)
            }
        }
    }
    
    /// Returns all of `itemsController` root-level nodes' represented objects
    func boxNodes() -> [BoxNode] {
        let rootNodes = treeController.arrangedObjects.childNodes!! as [NSTreeNode]
        return rootNodes.map { (treeNode: NSTreeNode) -> BoxNode in
            return treeNode.representedObject as BoxNode
        }
    }
    
    
    // MARK: -
    // MARK: Add Boxes
    
    @IBOutlet public weak var orderBoxButton: NSButton!

    @IBAction public func orderBox(sender: AnyObject) {
        if let eventHandler = self.eventHandler {
            eventHandler.createBox()
        }
    }
    
    // MARK: Consume box data
    
    public func consume(boxData: BoxData) {
        let boxNode = self.boxNode(boxData)
        let indexPath = NSIndexPath(index: nodeCount())
        treeController.insertObject(boxNode, atArrangedObjectIndexPath: indexPath)
        orderTree()
        
        delay(3, { () -> () in
            boxNode.title = "TEST!!"
        })
    }
    
    func boxNode(boxData: BoxData) -> BoxNode {
        let boxNode = BoxNode(boxData: boxData)
        // TODO: test the title setup
        //        boxNode.title = boxData.title
        boxNode.eventHandler = self
        boxNode.children = itemNodes(boxData.itemData)
        
        return boxNode
    }
    
    func itemNodes(allItemData: [ItemData]) -> [ItemNode] {
        var result: [ItemNode] = allItemData.map() { (itemData: ItemData) -> ItemNode in
            self.itemNode(itemData)
        }
        return result
    }
    
    func itemNode(itemData: ItemData) -> ItemNode {
        let itemNode = ItemNode(itemData: itemData)
        // TODO: test the title setup
        //        itemNode.title = itemData.title
        itemNode.eventHandler = self
        
        return itemNode
    }
    
    
    // MARK: -
    // MARK: Add item
    
    @IBOutlet public weak var addItemButton: NSButton!
    @IBOutlet public weak var removeSelectionButton: NSButton!
    
    
    @IBAction public func addItem(sender: AnyObject) {
        if !hasBoxes() {
            return
        }
        
        if let eventHandler = self.eventHandler {
            eventHandler.createItem()
        }
    }
    
    
    // MARK: Consume item data
    
    public func consume(itemData: ItemData) {
        if let boxId = itemData.boxId {
            if let boxNode = existingBoxNode(boxId) {
                let itemId = itemData.itemId
                let itemNode = self.itemNode(itemData)
                
                boxNode.addItemNode(itemNode)
                orderTree()
            }
        }
    }
    
    func existingBoxNode(boxId: BoxId) -> BoxNode? {
        let boxNodes = treeController.arrangedObjects.childNodes!! as [NSTreeNode]
        for treeNode in boxNodes {
            let boxNode = treeNode.representedObject as BoxNode
            if boxNode.boxId == boxId {
                return boxNode
            }
        }
        return nil
    }
    
    // MARK: -
    // MARK: Remove selection
    
    @IBAction public func removeSelectedObject(sender: AnyObject) {
        if (!hasSelection()) {
            return
        }
        
        let firstSelectedTreeNode: NSTreeNode = treeController.selectedNodes.first! as NSTreeNode
        let indexPath = firstSelectedTreeNode.indexPath
        let treeNode: TreeNode = firstSelectedTreeNode.representedObject as TreeNode
        
        if let boxNode = treeNode as? BoxNode {
            eventHandler.removeBox(boxNode.boxId)
        } else if let itemNode = treeNode as? ItemNode {
            if let boxNode = itemNode.parentBoxNode(inArray: boxNodes()) {
                eventHandler.removeItem(itemNode.itemId, fromBox: boxNode.boxId)
            }
        }
    }
    
    // MARK: - 
    // MARK: Populate view
    
    //MARK: Populate View
    
    public func displayBoxData(boxData: [BoxData]) {
        removeExistingNodes()
        for data in boxData {
            treeController.addObject(boxNode(data))
        }
    }
    
    func removeExistingNodes() {
        treeController.content = NSMutableArray()
    }
}
