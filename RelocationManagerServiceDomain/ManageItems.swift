//
//  ManageItems.swift
//  RelocationManager
//
//  Created by Christian Tietze on 24/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class ManageItems {
 
    public lazy var itemRepository: ItemRepository = ServiceLocator.itemRepository()
    public lazy var distributionService: DistributeItem = DomainRegistry.sharedInstance.distributeItem()
    
    public init() { }
    
    // MARK: Create/delete Item
    
    public func distributeItem(title: String) {
        distributionService.distribute(itemTitle: title)
    }
    
    public func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
        let itemId = ItemId(itemIdentifier)
        let boxId = BoxId(boxIdentifier)
        
        if let item = itemRepository.item(itemId: itemId) {
            ///// TODO add remove event in domain: box.removeItem(item, repo)
        }
    }
}