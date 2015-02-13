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

public class BoxViewController: NSViewController, NSOutlineViewDelegate, HandlesItemListChanges {
    
    public weak var eventHandler: HandlesItemListEvents!
    
    // MARK: -
    // MARK: Outline
    
    public var outlineView: NSOutlineView {
        return self.view as NSOutlineView
    }
    
    @IBOutlet public weak var itemsController: NSTreeController!
    
    var itemsSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: "caseInsensitiveCompare:")
        
        return [sortByTitle]
    }
    
    func orderTree() {
        itemsController.rearrangeObjects()
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
        let rootNodes = itemsController.arrangedObjects.childNodes!! as [NSTreeNode]
        return rootNodes.map { (treeNode: NSTreeNode) -> BoxNode in
            return treeNode.representedObject as BoxNode
        }
    }
    
    
    // MARK: -
    // MARK: Button Callbacks
    
    @IBOutlet public weak var orderBoxButton: NSButton!
    @IBOutlet public weak var addItemButton: NSButton!
    @IBOutlet public weak var removeSelectionButton: NSButton!
    
    @IBAction public func orderBox(sender: AnyObject) {
    }
    
    
    @IBAction public func addItem(sender: AnyObject) {
    }
    
    
    @IBAction public func removeSelectedObject(sender: AnyObject) {
    }
}
