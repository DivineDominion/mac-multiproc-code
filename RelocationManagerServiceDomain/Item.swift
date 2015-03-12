//
//  Item.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 16.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public struct ItemId: Equatable, Hashable, DebugPrintable, Identifiable {
    public var identifier: IntegerId { return _identifier }
    private var _identifier: IntegerId
    
    public var number: NSNumber { return NSNumber(longLong: identifier) }
    
    public init(_ identifier: IntegerId) {
        _identifier = identifier
    }
    
    init(_ identifierNumber: NSNumber) {
        _identifier = identifierNumber.longLongValue
    }
    
    public var debugDescription: String {
        return "ItemId: \(identifier)"
    }
    
    public var hashValue: Int {
        return self._identifier.hashValue
    }
}

public func ==(lhs: ItemId, rhs: ItemId) -> Bool {
    return lhs.identifier == rhs.identifier
}

public protocol ProvidesBoxItems {
    func items(#boxId: BoxId) -> [Item]
}

public protocol ItemRepository: ProvidesBoxItems {
    func nextId() -> ItemId
    func addItem(item: Item)
    func items() -> [Item]
    func count() -> Int
}

public class Item: NSObject {
    public let itemId: ItemId
    public dynamic var title: String
    public private(set) var boxId: BoxId {
        didSet {
            boxIdentifier = self.boxId.identifier
        }
    }
    public dynamic var boxIdentifier: IntegerId
    
    public init(itemId: ItemId, title: String, boxId: BoxId) {
        self.itemId = itemId
        self.title = title
        self.boxId = boxId
        self.boxIdentifier = boxId.identifier
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? Item {
            return other.itemId == self.itemId
        }
        
        return false
    }
    
    public override var hashValue: Int {
        return 173 &+ self.itemId.hashValue
    }
    
    public func moveToBox(box: Box) {
        boxId = box.boxId
    }
}

public func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.itemId == rhs.itemId
}
