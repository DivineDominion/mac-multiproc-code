//
//  DomainRegistry.swift
//  RelocationManager
//
//  Created by Christian Tietze on 05/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

private struct DomainRegistryStatic {
    static var singleton: DomainRegistry? = nil
    static var onceToken: dispatch_once_t = 0
}

public class DomainRegistry {
    
    public init() { }
    public class var sharedInstance: DomainRegistry {
        
        if DomainRegistryStatic.singleton == nil {
            dispatch_once(&DomainRegistryStatic.onceToken) {
                self.setSharedInstance(DomainRegistry())
            }
        }
        
        return DomainRegistryStatic.singleton!
    }
    
    /// Reset the static `sharedInstance`, for example for testing
    public class func resetSharedInstance() {
        DomainRegistryStatic.singleton = nil
        DomainRegistryStatic.onceToken = 0
    }
    
    public class func setSharedInstance(instance: DomainRegistry) {
        DomainRegistryStatic.singleton = instance
    }
    
    // MARK: Registry Accessors
    
    public func boxRepository() -> BoxRepository {
        return ServiceLocator.boxRepository()
    }
    
    lazy var _distributeItem: DistributeItem = DistributeItem(boxRepository: self.boxRepository(), provisioningService: self.provisioningService())
    public func distributeItem() -> DistributeItem {
        return _distributeItem
    }
    
    public func provisioningService() -> ProvisioningService {
        return ProvisioningService(repository: boxRepository())
    }
}
