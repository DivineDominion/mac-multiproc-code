//
//  TestDomainRegistry.swift
//  RelocationManager
//
//  Created by Christian Tietze on 09/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class TestDomainRegistry: DomainRegistry {
        
    var testProvisioningService = NullProvisioningService()
    override func provisioningService() -> ProvisioningService {
        return testProvisioningService
    }
    
    var testDistributeItem = NullDistributeItem()
    override func distributeItem() -> DistributeItem {
        return testDistributeItem
    }
    
    var testDissolveBox = NullDissolveBox()
    override func dissolveBox() -> DissolveBox {
        return testDissolveBox
    }
    
    var testRemoveItem = NullRemoveItem()
    override func removeItem() -> RemoveItem {
        return testRemoveItem
    }
}
