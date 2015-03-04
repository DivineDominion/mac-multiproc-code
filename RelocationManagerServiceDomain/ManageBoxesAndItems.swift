//
//  ManageBoxesAndItems.swift
//  RelocationManager
//
//  Created by Christian Tietze on 24/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class ManageBoxesAndItems: ManagesBoxesAndItems {
    
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
    
    
    // MARK: Provisioning
    
    public func provisionBox(label: String, capacity: Int) {
        if let boxCapacity = BoxCapacity(rawValue: capacity) {
            provisioningService.provisionBox(label, capacity: boxCapacity)
        }
    }
    
    public func provisionItem(title: String) {
        distributionService.distribute(itemTitle: title, provisioningService: provisioningService, boxRepository: repository)
    }
    
    
    // MARK: Removing
    
    public func removeBox(boxIdentifier: IntegerId) {
        
    }
    
    public func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
        
    }
}