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
    
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    public init(boxId: BoxId, capacity: BoxCapacity, title: String) {
        self.boxId = boxId
        self.capacity = capacity
        self.title = title
    }
    
    public func item(itemTitle: String, provisioningService: ProvisioningService) -> Item {
        let itemId = provisioningService.nextItemId()
        return Item(itemId: itemId, title: title, boxId: boxId)
    }
    
    public func itemsCount(itemRepository: ItemRepository) -> Int {
        return itemRepository.items(boxId: boxId).count
    }
    
    public func isFull(itemRepository: ItemRepository) -> Bool {
        return remainingCapacity(itemRepository) <= 0
    }
    
    func remainingCapacity(itemRepository: ItemRepository) -> Int {
        let capacity = self.capacity.rawValue
        let load = itemsCount(itemRepository)
        
        return capacity - load
    }
}
