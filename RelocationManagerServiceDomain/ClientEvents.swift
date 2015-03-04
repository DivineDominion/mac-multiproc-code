//
//  ClientEvents.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public protocol ClientEvent {
    var dictionaryRepresentation: NSDictionary { get }
}

public enum ClientEvents: String {
    case DistributingItemFailed = "Distributing Item Failed"
    case BoxCreated = "Box Created"
    
    public func name() -> String {
        return rawValue
    }
}

struct DistributingItemFailed: ClientEvent {
    let eventType = ClientEvents.DistributingItemFailed
    let itemTitle: String
    
    init(itemTitle: String) {
        self.itemTitle = itemTitle
    }
    
    var dictionaryRepresentation: NSDictionary {
        return [ eventType.name() : [
            "item" : [
                "title" : itemTitle
            ]
        ] ]
    }
}

struct BoxCreated: ClientEvent {
    let eventType = ClientEvents.BoxCreated
    let boxId: BoxId
    let boxLabel: String
    let boxCapacity: BoxCapacity
    
    init(boxId: BoxId, boxLabel: String, boxCapacity: BoxCapacity) {
        self.boxId = boxId
        self.boxLabel = boxLabel
        self.boxCapacity = boxCapacity
    }
    
    var dictionaryRepresentation: NSDictionary {
        return [ eventType.name() : [
            "box" : [
                "id" : boxId.number,
                "label" : boxLabel,
                "capacity" : boxCapacity.rawValue
            ]
        ] ]
    }
}
