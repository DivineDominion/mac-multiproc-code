//
//  ManageItems.swift
//  RelocationManager
//
//  Created by Christian Tietze on 24/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class ManageItems {
 
    public lazy var distributionService: DistributeItem = DomainRegistry.sharedInstance.distributeItem()
    public lazy var removalService: RemoveItem = DomainRegistry.sharedInstance.removeItem()
    
    public init() { }
    
    public func distributeItem(title: String) {
        ServiceLocator.unitOfWork().execute {
            self.distributionService.distribute(itemTitle: title)
        }
    }
    
    public func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
        let itemId = ItemId(itemIdentifier)
        let boxId = BoxId(boxIdentifier)
        
        ServiceLocator.unitOfWork().execute {
            self.removalService.remove(itemId, fromBox: boxId)
        }
    }
}
