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
    
    public lazy var distributionService: DistributeItem = DomainRegistry.sharedInstance.distributeItem()
    
    public init() {
        self.subscribeToBoxItemAddingFailed()
    }
    
    var addingBoxItemFailedSubscriber: DomainEventSubscription!
    
    func subscribeToBoxItemAddingFailed() {
        addingBoxItemFailedSubscriber = eventPublisher.subscribe(AddingBoxItemFailed.self) {
            [unowned self] event in
            
            self.distributeItem(event.itemTitle)
        }
    }
    
    public func distributeItem(title: String) {
        distributionService.distribute(itemTitle: title)
    }
    
    public func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
        
    }
}