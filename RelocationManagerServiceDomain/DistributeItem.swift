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
    
    let repository: BoxRepository
    let provisioningService: ProvisioningService
    
    public init(boxRepository: BoxRepository, provisioningService: ProvisioningService) {
        self.repository = boxRepository
        self.provisioningService = provisioningService
    }
    
    
    public func distribute(itemTitle title: String) {
        let boxes = nonFullBoxesSortedByFill()

        if let box = boxes.first {
            provisioningService.provisionItem(title, inBox: box)
            return
        }
        
        eventPublisher.publish(BoxItemDistributionFailed(itemTitle: title))
    }
    
    func nonFullBoxesSortedByFill() -> [Box] {
        return repository.boxes().filter { box in
            return box.canTakeItem()
        }.sorted { (one, other) -> Bool in
            return one.itemsCount < other.itemsCount
        }
    }
    
    func nonFullBoxesSortedByFillExcept(box: Box) -> [Box] {
        return nonFullBoxesSortedByFill().filter { return $0 != box }
    }
    
}