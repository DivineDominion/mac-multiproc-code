//
//  DistributeItem.swift
//  RelocationManager
//
//  Created by Christian Tietze on 23/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class DistributeItem: RedistributesItems {
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
    
    // MARK: Distributing a Single Item
    
    public func distribute(itemTitle title: String) {
        let boxes = nonFullBoxesSortedByLoad()

        distributeItem(itemTitle: title, among: boxes)
    }
    
    func distributeItem(itemTitle title: String, among boxes: [Box]) {
        if let box = boxes.first {
            provisioningService.provisionItem(title, inBox: box)
            return
        }
        
        eventPublisher.publish(BoxItemDistributionFailed(itemTitle: title))
    }
    
    func nonFullBoxesSortedByLoad() -> [Box] {
        let allBoxes = boxRepository.boxes()

        // TODO Both methods query the repository which is wasteful.
        return allBoxes.filter(boxCanTakeItem).sorted(boxHasLessItems)
    }
    
    func boxCanTakeItem(box: Box) -> Bool {
        return !box.isFull(itemRepository) && !box.locked
    }
    
    func boxHasLessItems(one: Box, _ other: Box) -> Bool {
        return itemsCount(one) < itemsCount(other)
    }
    
    func itemsCount(box: Box) -> Int {
        return box.itemsCount(itemRepository)
    }
    
    
    // MARK: Dissolving a Box's contents
    
    public func redistributeItems(box: Box) {
        if totalRemainingCapacityInsufficient(box) {
            eventPublisher.publish(BoxItemsRedistributionFailed(boxId: box.boxId))
            return
        }
        
        moveItems(box)
    }
    
    func totalRemainingCapacityInsufficient(box: Box) -> Bool {
        let otherBoxes = nonFullBoxesSortedByLoadExcept(box)
        let totalRemainingCapacity = otherBoxes.reduce(0, combine: remainingCapacity)
        
        return totalRemainingCapacity < itemsCount(box)
    }
    
    func nonFullBoxesSortedByLoadExcept(box: Box) -> [Box] {
        return nonFullBoxesSortedByLoad().filter { return $0 != box }
    }
    
    func remainingCapacity(initialCapacity: Int, box: Box) -> Int {
        return initialCapacity + remainingCapacity(box)
    }
    
    func remainingCapacity(box: Box) -> Int {
        return box.remainingCapacity(itemRepository)
    }
    
    func moveItems(box: Box) {
        let items = itemRepository.items(boxId: box.boxId)
        
        for item in items {
            let otherBoxes = nonFullBoxesSortedByLoadExcept(box)
            
            if let newBox = otherBoxes.first {
                item.moveToBox(newBox)
            }
        }
    }
}