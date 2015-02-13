//
//  BoxAndItemTreeNodes.swift
//  RelocationManager
//
//  Created by Christian Tietze on 13/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

@objc(TreeNode)
public protocol TreeNode {
    var title: String { get set }
    var capacity: UInt { get set }
    var children: [TreeNode] { get }
    var isLeaf: Bool { get }
    weak var eventHandler: HandlesItemListChanges? { get }
}

@objc(HandlesItemListChanges)
public protocol HandlesItemListChanges: class {
    func treeNodeDidChange(treeNode: TreeNode, title: String)
}

public class BoxNode: NSObject, TreeNode {
    class var defaultTitle: String! { return "Box" }
    public dynamic var title: String = BoxNode.defaultTitle {
        didSet {
            if let controller = self.eventHandler {
                controller.treeNodeDidChange(self, title: title)
            }
        }
    }
    public dynamic var capacity: UInt = 0
    public dynamic var children: [TreeNode] = []
    public dynamic var isLeaf: Bool = false
    public let boxId: BoxId
    public weak var eventHandler: HandlesItemListChanges?
    
    public init(boxId: BoxId) {
        self.boxId = boxId
    }
    
    public init(boxData: BoxData) {
        self.boxId = boxData.boxId
        self.title = boxData.title
        super.init()
    }
    
    public func addItemNode(itemNode: ItemNode) {
        children.append(itemNode)
    }
}

public class ItemNode: NSObject, TreeNode {
    class var defaultTitle: String! { return "Item" }
    public dynamic var title: String = ItemNode.defaultTitle {
        didSet {
            if let controller = self.eventHandler {
                controller.treeNodeDidChange(self, title: title)
            }
        }
    }
    public dynamic var capacity: UInt = 0
    public dynamic var children: [TreeNode] = []
    public dynamic var isLeaf = true
    public let itemId: ItemId
    public weak var eventHandler: HandlesItemListChanges?
    
    public init(itemId: ItemId) {
        self.itemId = itemId
    }
    
    public init(itemData: ItemData) {
        self.itemId = itemData.itemId
        self.title = itemData.title
    }
    
    public func parentBoxNode(inArray nodes: [BoxNode]) -> BoxNode? {
        for boxNode in nodes {
            if contains(boxNode.children as [ItemNode], self) {
                return boxNode
            }
        }
        
        return nil
    }
}
