//
//  ManageBoxesAndItems.swift
//  RelocationManager
//
//  Created by Christian Tietze on 24/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class ManageBoxesAndItems: NSObject, ManagesBoxesAndItems {
    public lazy var repository: BoxRepository = ServiceLocator.boxRepository()
    public lazy var provisioningService: ProvisioningService = ProvisioningService(repository: self.repository)
    public lazy var distributionService = DistributeItem()
    
    public func provisionBox(label: String, capacity: Int) {
        if let boxCapacity = BoxCapacity(rawValue: capacity) {
            provisioningService.provisionBox(label, capacity: boxCapacity)
        }
    }
    
    public func provisionItem(title: String) {
        distributionService.distribute(itemTitle: title, provisioningService: provisioningService, boxRepository: repository)
    }
    
    public func removeBox(boxIdentifier: IntegerId) {
        
    }
    
    public func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
        
    }
}