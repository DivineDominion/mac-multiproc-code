//
//  ManageItems.swift
//  RelocationManager
//
//  Created by Christian Tietze on 24/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class ManageItems {
    
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    public lazy var repository: BoxRepository = ServiceLocator.boxRepository()
    public lazy var provisioningService: ProvisioningService = ProvisioningService(repository: self.repository)
    public lazy var distributionService = DistributeItem()
    
    public init() {
        self.subscribeToBoxItemAddingFailed()
    }
    
    var addingBoxItemFailedSubscriber: DomainEventSubscriber!
    
    func subscribeToBoxItemAddingFailed() {
        addingBoxItemFailedSubscriber = eventPublisher.subscribe(AddingBoxItemFailed.self) {
            [unowned self] event in
            
            self.distributeItem(event.itemTitle)
        }
    }
    
    public func distributeItem(title: String) {
        distributionService.distribute(itemTitle: title, provisioningService: provisioningService, boxRepository: repository)
    }
    
    public func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
        
    }
}