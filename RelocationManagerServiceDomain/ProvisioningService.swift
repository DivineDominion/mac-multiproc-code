//
//  ProvisioningService.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 03/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

public class ProvisioningService {
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    let boxRepository: BoxRepository
    let itemRepository: ItemRepository
    public lazy var identityService: IdentityService = IdentityService(boxRepository: self.boxRepository, itemRepository: self.itemRepository)
    
    public init(boxRepository: BoxRepository, itemRepository: ItemRepository) {
        self.boxRepository = boxRepository
        self.itemRepository = itemRepository
    }
    
    public func provisionBox(title: String, capacity: BoxCapacity) {
        let boxId = identityService.nextBoxId()
        let box = Box(boxId: boxId, capacity: capacity, title: title)
        
        boxRepository.addBox(box)
        
        eventPublisher.publish(BoxProvisioned(boxId: boxId, capacity: capacity.rawValue, title: title))
    }
    
    public func provisionItem(title: String, inBox box: Box) {
        let item = box.item(title, identityService: identityService)
        
        itemRepository.addItem(item)
        
        eventPublisher.publish(ItemProvisioned(itemId: item.itemId, title: item.title))
    }
}
