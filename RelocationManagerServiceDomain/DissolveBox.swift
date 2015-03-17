//
//  DissolveBox.swift
//  RelocationManager
//
//  Created by Christian Tietze on 12/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public protocol RedistributesItems {
    func redistributeItems(box: Box)
}

public class DissolveBox {
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    let distributionService: DistributeItem
    let boxRepository: BoxRepository
    let itemRepository: ItemRepository
    
    public init(boxRepository: BoxRepository, itemRepository: ItemRepository, distributionService: DistributeItem) {
        self.distributionService = distributionService
        self.boxRepository = boxRepository
        self.itemRepository = itemRepository
    }
    
    public func dissolve(box: Box) {
        box.lock()
        box.dissolve(distributionService)
        
        if !box.isEmpty(itemRepository) {
            eventPublisher.publish(BoxRemovalFailed(boxId: box.boxId))
            box.unlock()
            return
        }
        
        boxRepository.removeBox(boxId: box.boxId)
        
        eventPublisher.publish(BoxRemoved(boxId: box.boxId))
    }
}