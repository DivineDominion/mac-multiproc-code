//
//  ProvisioningService.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 03/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

public class ProvisioningService {
    let repository: BoxRepository
    
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    public init(repository: BoxRepository) {
        self.repository = repository
    }
    
    public func provisionBox(title: String, capacity: BoxCapacity) {
        let boxId = repository.nextId()
        let box = Box(boxId: boxId, capacity: capacity, title: title)
        
        repository.addBox(box)
        
        eventPublisher.publish(BoxProvisionedEvent(boxId: boxId, capacity: capacity.rawValue, title: title))
    }
    
    public func provisionItem(title: String, inBox box: Box) {
        let itemId = repository.nextItemId()
        let item = Item(itemId: itemId, title: title)

        box.addItem(item)
    }
}
