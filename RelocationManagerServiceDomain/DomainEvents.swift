//
//  DomainEvents.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 04/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

public typealias UserInfo = [NSObject : AnyObject]

public enum DomainEventType: String {
    case BoxProvisioned = "Box Provisioned"
    case ItemProvisioned = "Item Provisioned"
    
    case ItemDistributionFailed = "Item Distribution Failed"

    case BoxRemoved = "Box Removed"
    case BoxRemovalFailed = "Box Removal Failed"
    case BoxItemsRedistributionFailed = "Box Items Redistribution Failed"

    case ItemRemoved = "Item Removed"
    case ItemRemovalFailed = "Item RemovalFailed"

    var name: String {
        return self.rawValue
    }
}

public protocol DomainEvent {
    /// The `DomainEventType` to identify this kind of DomainEvent
    static var eventType: DomainEventType { get }
    
    init(userInfo: UserInfo)
    func userInfo() -> UserInfo
    func notification() -> NSNotification
}

public struct BoxProvisioned: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.BoxProvisioned
    }
    
    public let boxId: BoxId
    public let capacity: Int
    public let title: String
    
    public init(boxId: BoxId, capacity: Int, title: String) {
        self.boxId = boxId
        self.capacity = capacity
        self.title = title
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as! UserInfo
        let boxIdData = boxData["id"] as! NSNumber
        let boxCapacity = boxData["capacity"] as! Int
        let boxTitle = boxData["title"] as! String
        
        self.init(boxId: BoxId(boxIdData), capacity: boxCapacity, title: boxTitle)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "box": [
                "id": boxId.number,
                "capacity": capacity,
                "title": title
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct ItemProvisioned: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.ItemProvisioned
    }
    
    public let itemId: ItemId
    public let title: String
    
    public init(itemId: ItemId, title: String) {
        self.itemId = itemId
        self.title = title
    }
    
    public init(userInfo: UserInfo) {
        let itemData = userInfo["item"] as! UserInfo
        let itemIdData = itemData["id"] as! NSNumber
        let itemTitle = itemData["title"] as! String
        
        self.init(itemId: ItemId(itemIdData), title: itemTitle)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "item": [
                "id": itemId.number,
                "title": title
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}


public struct ItemRemoved: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.ItemRemoved
    }
    
    public let itemId: ItemId
    
    public init(itemId: ItemId) {
        self.itemId = itemId
    }
    
    public init(userInfo: UserInfo) {
        let itemData = userInfo["item"] as! UserInfo
        let itemIdData = itemData["id"] as! NSNumber
        let itemId = ItemId(itemIdData)
        
        self.init(itemId: itemId)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "item" : [
                "id" : itemId.number
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct ItemRemovalFailed: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.ItemRemovalFailed
    }
    
    public let itemId: ItemId
    public let boxId: BoxId
    
    public init(itemId: ItemId, boxId: BoxId) {
        self.itemId = itemId
        self.boxId = boxId
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as! UserInfo
        let boxIdData = boxData["id"] as! NSNumber
        let boxId = BoxId(boxIdData)

        let itemData = userInfo["item"] as! UserInfo
        let itemIdData = itemData["id"] as! NSNumber
        let itemId = ItemId(itemIdData)
        
        self.init(itemId: itemId, boxId: boxId)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "item" : [
                "id" : itemId.number
            ],
            "box" : [
                "id" : boxId.number
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct ItemDistributionFailed: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.ItemDistributionFailed
    }
    
    public let itemTitle: String
    
    public init(itemTitle: String) {
        self.itemTitle = itemTitle
    }
    
    public init(userInfo: UserInfo) {
        let itemData = userInfo["item"] as! UserInfo
        let itemTitle = itemData["title"] as! String
        
        self.init(itemTitle: itemTitle)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "item" : [
                "title": itemTitle
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct BoxRemoved: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.BoxRemoved
    }
    
    public let boxId: BoxId
    
    public init(boxId: BoxId) {
        self.boxId = boxId
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as! UserInfo
        let boxIdData = boxData["id"] as! NSNumber
        let boxId = BoxId(boxIdData)
        
        self.init(boxId: boxId)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "box": [
                "id": boxId.number
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct BoxRemovalFailed: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.BoxRemovalFailed
    }
    
    public let boxId: BoxId
    
    public init(boxId: BoxId) {
        self.boxId = boxId
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as! UserInfo
        let boxIdData = boxData["id"] as! NSNumber
        let boxId = BoxId(boxIdData)
        
        self.init(boxId: boxId)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "box": [
                "id": boxId.number
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct BoxItemsRedistributionFailed: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.BoxItemsRedistributionFailed
    }
    
    public let boxId: BoxId
    
    public init(boxId: BoxId) {
        self.boxId = boxId
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as! UserInfo
        let boxIdData = boxData["id"] as! NSNumber
        let boxId = BoxId(boxIdData)
        
        self.init(boxId: boxId)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "box": [
                "id": boxId.number
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}
