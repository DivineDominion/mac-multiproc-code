//
//  ConnectionController.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class ConnectionController {
    let connection: Connection
    
    public init(connection: Connection) {
        self.connection = connection
        self.subscribeToItemDistributionFailed()
    }
    
    func send(event: ClientEvent) {
        connection.send(event)
    }
    
    // MARK: Notify about failed item distribution
    
    var distributionFailedSubscription: DomainEventSubscription!
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    func subscribeToItemDistributionFailed() {
        distributionFailedSubscription = eventPublisher.subscribe(BoxItemDistributionFailed.self) {
            [unowned self] event in
            
            self.send(DistributingItemFailed(itemTitle: event.itemTitle))
        }
    }
}