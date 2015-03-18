//
//  RemoveItem.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class RemoveItem {
    
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    let itemRepository: ItemRepository
    
    public init(itemRepository: ItemRepository) {
        self.itemRepository = itemRepository
    }
    
    public func remove(itemId: ItemId, fromBox boxId: BoxId) {
        if !itemExists(itemId, inBox: boxId) {
            eventPublisher.publish(ItemRemovalFailed(itemId: itemId, boxId: boxId))
            return
        }
        
        itemRepository.removeItem(itemId: itemId)
        
        eventPublisher.publish(ItemRemoved(itemId: itemId))
    }
    
    func itemExists(itemId: ItemId, inBox boxId: BoxId) -> Bool {
        if let item = itemRepository.item(itemId: itemId) {
            return item.boxId == boxId
        }
        
        return false
    }
}
