//
//  DistributeItem.swift
//  RelocationManager
//
//  Created by Christian Tietze on 23/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class DistributeItem {
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    let boxRepository: BoxRepository
    let itemRepository: ItemRepository
    let provisioningService: ProvisioningService
    
    public init(boxRepository: BoxRepository, itemRepository: ItemRepository, provisioningService: ProvisioningService) {
        self.boxRepository = boxRepository
        self.itemRepository = itemRepository
        self.provisioningService = provisioningService
    }
    
    public func distribute(itemTitle title: String) {
        let boxes = nonFullBoxesSortedByLoad()

        if let box = boxes.first {
            provisioningService.provisionItem(title, inBox: box)
            return
        }
        
        eventPublisher.publish(BoxItemDistributionFailed(itemTitle: title))
    }
    
    func nonFullBoxesSortedByLoad() -> [Box] {
        let allBoxes = boxRepository.boxes()

        // Both methods query the repository which is wasteful.
        return allBoxes.filter(boxCanTakeItem).sorted(boxHasLessItems)
    }
    
    func boxCanTakeItem(box: Box) -> Bool {
        return !box.isFull(itemRepository)
    }
    
    func boxHasLessItems(one: Box, _ other: Box) -> Bool {
        return itemsCount(one) < itemsCount(other)
    }
    
    func itemsCount(box: Box) -> Int {
        return box.itemsCount(itemRepository)
    }
    
    func nonFullBoxesSortedByLoadExcept(box: Box) -> [Box] {
        return nonFullBoxesSortedByLoad().filter { return $0 != box }
    }
    
}