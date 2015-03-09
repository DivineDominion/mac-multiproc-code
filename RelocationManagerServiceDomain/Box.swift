//
//  Box.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public struct BoxId: Equatable, DebugPrintable, Identifiable {
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
        return "BoxId: \(identifier)"
    }
}

public func ==(lhs: BoxId, rhs: BoxId) -> Bool {
    return lhs.identifier == rhs.identifier
}

public protocol BoxRepository {
    func nextId() -> BoxId
    func nextItemId() -> ItemId
    func addBox(box: Box)
    func removeBox(#boxId: BoxId)
    func boxes() -> [Box]
    func box(#boxId: BoxId) -> Box?
    func count() -> Int
}

public enum BoxCapacity: Int {
    case Small = 5
    case Medium = 10
    case Large = 20
}

public class Box: NSObject {
    public let boxId: BoxId
    public dynamic var title: String
    public let capacity: BoxCapacity
    public var remainingCapacity: Int {
        return capacity.rawValue - itemsCount
    }
    dynamic var items: [Item] = []
    public var itemsCount: Int {
        return items.count
    }
    
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    public init(boxId: BoxId, capacity: BoxCapacity, title: String) {
        self.boxId = boxId
        self.capacity = capacity
        self.title = title
    }
    
    public func addItem(item: Item) {
        assert(item.box == nil, "item should not have a parent box already")
        
        if isFull() {
            eventPublisher.publish(AddingBoxItemFailed(boxId: boxId, itemId: item.itemId, itemTitle: item.title))
            return
        }
        
        items.append(item)
        
        eventPublisher.publish(BoxItemAdded(boxId: boxId, itemId: item.itemId, itemTitle: item.title))
    }
    
    public func item(#itemId: ItemId) -> Item? {
        if let index = indexOfItem(itemId: itemId) {
            return items[index]
        }
        
        return nil
    }
    
    public func removeItem(#itemId: ItemId) {
        if let index = indexOfItem(itemId: itemId) {
            items.removeAtIndex(index)
            
            eventPublisher.publish(BoxItemRemoved(boxId: boxId, itemId: itemId))
        }
    }
    
    func indexOfItem(#itemId: ItemId) -> Int? {
        for (index, item) in enumerate(items) {
            if item.itemId == itemId {
                return index
            }
        }
        
        return nil
    }
    
    public func canTakeItem() -> Bool {
        return !isFull()
    }
    
    public func isFull() -> Bool {
        return remainingCapacity <= 0
    }
}
