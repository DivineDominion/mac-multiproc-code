//
//  ManageBoxesAndItems.swift
//  RelocationManager
//
//  Created by Christian Tietze on 24/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

class ManageBoxesAndItems: NSObject, ManagesBoxesAndItems {
    var repository: BoxRepository {
        return ServiceLocator.boxRepository()
    }
    var provisioningService: ProvisioningService {
        return ProvisioningService(repository: self.repository)
    }
    var distributionService = DistributeItem()
    
    func provisionBox(label: String, capacity: Int) {
        if let boxCapacity = BoxCapacity(rawValue: capacity) {
            provisioningService.provisionBox(capacity: boxCapacity)
        }
    }
    
    func provisionItem(name: String) {
        distributionService.distribute(itemTitle: name, provisioningService: provisioningService, boxRepository: repository)
    }
    
    func removeBox(boxIdentifier: IntegerId) {
        
    }
    
    func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId) {
        
    }
}