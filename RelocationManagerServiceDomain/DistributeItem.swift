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
    
    public init() { }
    
    public func distribute(itemTitle title: String, provisioningService: ProvisioningService, boxRepository repository: BoxRepository) {
        
        if let box = boxes(fromRepository: repository).first {
            provisioningService.provisionItem(title, inBox: box)
            return
        }
        
        eventPublisher.publish(BoxItemDistributionFailed(itemTitle: title))
    }
    
    func boxes(fromRepository repository: BoxRepository) -> [Box] {
        return repository.boxes().filter { box in
            return box.canTakeItem()
        }.sorted { (one, other) -> Bool in
                return one.itemsCount < other.itemsCount
        }
    }
}