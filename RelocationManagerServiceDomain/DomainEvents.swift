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
    
    case BoxItemAdded = "Box Item Added"
    case AddingBoxItemFailed = "Adding Box Item Failed"
    case BoxItemRemoved = "Box Item Removed"
    
    case BoxItemDistributionFailed = "Box Item Distribution Failed"
    
    var name: String {
        return self.rawValue
    }
}

public protocol DomainEvent {
    /// The `DomainEventType` to identify this kind of DomainEvent
    class var eventType: DomainEventType { get }
    
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
        let boxIdData = userInfo["id"] as NSNumber
        let boxCapacity = userInfo["capacity"] as Int
        let boxTitle = userInfo["title"] as String
        
        self.init(boxId: BoxId(boxIdData), capacity: boxCapacity, title: boxTitle)
    }
    
    public func userInfo() -> UserInfo {
        // TODO replace NSNumber(...) by using StringLiteralConvertible
        return [
            "id": NSNumber(longLong: boxId.identifier),
            "capacity": capacity,
            "title": title
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct BoxItemAdded: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.BoxItemAdded
    }
    
    public let boxId: BoxId
    public let itemId: ItemId
    public let itemTitle: String
    
    public init(boxId: BoxId, itemId: ItemId, itemTitle: String) {
        self.boxId = boxId
        self.itemId = itemId
        self.itemTitle = itemTitle
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as UserInfo
        let boxIdData = boxData["id"] as NSNumber
        self.boxId = BoxId(boxIdData)
        
        let itemData = userInfo["item"] as UserInfo
        let itemIdData = itemData["id"] as NSNumber
        self.itemId = ItemId(itemIdData)
        self.itemTitle = itemData["title"] as String
    }
    
    public func userInfo() -> UserInfo {
        return [
            "box" : [
                "id" : NSNumber(longLong: boxId.identifier)
            ],
            "item" : [
                "id" : NSNumber(longLong: itemId.identifier),
                "title": itemTitle
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

// TODO resolve duplication of almost 100% of BoxItemAdded
public struct AddingBoxItemFailed: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.AddingBoxItemFailed
    }
    
    public let boxId: BoxId
    public let itemId: ItemId
    public let itemTitle: String
    
    public init(boxId: BoxId, itemId: ItemId, itemTitle: String) {
        self.boxId = boxId
        self.itemId = itemId
        self.itemTitle = itemTitle
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as UserInfo
        let boxIdData = boxData["id"] as NSNumber
        self.boxId = BoxId(boxIdData)
        
        let itemData = userInfo["item"] as UserInfo
        let itemIdData = itemData["id"] as NSNumber
        self.itemId = ItemId(itemIdData)
        self.itemTitle = itemData["title"] as String
    }
    
    public func userInfo() -> UserInfo {
        return [
            "box" : [
                "id" : NSNumber(longLong: boxId.identifier)
            ],
            "item" : [
                "id" : NSNumber(longLong: itemId.identifier),
                "title": itemTitle
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct BoxItemRemoved: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.BoxItemRemoved
    }
    
    public let boxId: BoxId
    public let itemId: ItemId
    
    public init(boxId: BoxId, itemId: ItemId) {
        self.boxId = boxId
        self.itemId = itemId
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as UserInfo
        let boxIdData = boxData["id"] as NSNumber
        self.boxId = BoxId(boxIdData)
        
        let itemData = userInfo["item"] as UserInfo
        let itemIdData = itemData["id"] as NSNumber
        self.itemId = ItemId(itemIdData)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "box" : [
                "id" : NSNumber(longLong: boxId.identifier)
            ],
            "item" : [
                "id" : NSNumber(longLong: itemId.identifier)
            ]
        ]
    }
    
    public func notification() -> NSNotification {
        return NSNotification(name: self.dynamicType.eventType.name, object: nil, userInfo: userInfo())
    }
}

public struct BoxItemDistributionFailed: DomainEvent {
    public static var eventType: DomainEventType {
        return DomainEventType.BoxItemDistributionFailed
    }
    
    public let itemTitle: String
    
    public init(itemTitle: String) {
        self.itemTitle = itemTitle
    }
    
    public init(userInfo: UserInfo) {
        let itemData = userInfo["item"] as UserInfo
        self.itemTitle = itemData["title"] as String
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
