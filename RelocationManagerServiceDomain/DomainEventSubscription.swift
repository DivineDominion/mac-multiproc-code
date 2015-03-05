//
//  DomainEventSubscription.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class DomainEventSubscription {
    
    let observer: NSObjectProtocol
    let eventPublisher: DomainEventPublisher
    
    public init(observer: NSObjectProtocol, eventPublisher: DomainEventPublisher) {
        self.observer = observer
        self.eventPublisher = eventPublisher
    }
    
    deinit {
        eventPublisher.unsubscribe(observer)
    }
}
