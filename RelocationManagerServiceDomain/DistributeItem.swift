//
//  DistributeItem.swift
//  RelocationManager
//
//  Created by Christian Tietze on 23/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class DistributeItem {
    let repository: BoxRepository
    let provisioningService: ProvisioningService
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    public init(repository: BoxRepository, provisioningService: ProvisioningService) {
        self.repository = repository
        self.provisioningService = provisioningService
    }
    
    public convenience init(repository: BoxRepository) {
        self.init(repository: repository, provisioningService: ProvisioningService(repository: repository))
    }
    
    public func distribute(itemTitle title: String) {
        if let box = boxes().first {
            provisioningService.provisionItem(title, inBox: box)
            return
        }
        
        eventPublisher.publish(BoxItemDistributionDidFail(itemTitle: title))
    }
    
    func boxes() -> [Box] {
        return repository.boxes().filter { box in
            return box.canTakeItem()
        }.sorted { (one, other) -> Bool in
                return one.itemsCount < other.itemsCount
        }
    }
}