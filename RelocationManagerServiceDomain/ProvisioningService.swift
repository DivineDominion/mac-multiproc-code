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
    
    let repository: BoxRepository
    
    public init(repository: BoxRepository) {
        self.repository = repository
    }
    
    public func provisionBox(title: String, capacity: BoxCapacity) {
        ProvisionBox(repository: repository).provisionBox(title, capacity: capacity)
    }
    
    public func provisionItem(title: String, inBox box: Box) {
        let itemId = repository.nextItemId()
        let item = Item(itemId: itemId, title: title)

        box.addItem(item)
    }
}

public class ProvisionBox {
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    let repository: BoxRepository
    
    public init(repository: BoxRepository) {
        self.repository = repository
    }
    
    public func provisionBox(title: String, capacity: BoxCapacity) {
        let boxId = repository.nextId()
        let box = Box(boxId: boxId, capacity: capacity, title: title)
        
        repository.addBox(box)
        
        eventPublisher.publish(BoxProvisioned(boxId: boxId, capacity: capacity.rawValue, title: title))
    }
    
    public func nextItemId() -> ItemId {
        return repository.nextItemId()
    }
}
