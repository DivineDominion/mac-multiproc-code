//
//  ConnectionController.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public protocol ConnectsToClient {
    func open()
    func close()
    func send(event: ClientEvent)
}

public class ConnectionController {
    let connection: ConnectsToClient
    
    public init(connection: ConnectsToClient) {
        self.connection = connection
        self.subscribeToItemDistributionFailed()
    }
    
    func openConnection() {
        connection.open()
    }
    
    func closeConnection() {
        connection.close()
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
        distributionFailedSubscription = eventPublisher.subscribe(ItemDistributionFailed.self) {
            [unowned self] event in
            
            self.send(DistributingItemFailed(itemTitle: event.itemTitle))
        }
    }
}
