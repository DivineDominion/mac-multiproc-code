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
    
    var addingBoxItemFailedSubscriber: DomainEventSubscriber!
    
    public init() {
        self.subscribeToBoxItemAddingFailed()
    }
    
    func subscribeToBoxItemAddingFailed() {
        addingBoxItemFailedSubscriber = eventPublisher.subscribe(AddingBoxItemFailed.self) {
            [unowned self] event in
            
            self.provisionItem(event.itemTitle)
        }
    }
    
    public func provisionItem(title: String) {
        distributionService.distribute(itemTitle: title, provisioningService: provisioningService, boxRepository: repository)
    }
    
    public func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
        
    }
}