//
//  NullServiceLocator.swift
//  RelocationManager
//
//  Created by Christian Tietze on 17/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class NullServiceLocator: ServiceLocator {
    class func registerAsSharedInstance() {
        ServiceLocator.setSharedInstance(NullServiceLocator())
    }
    
    override func unitOfWork() -> UnitOfWork {
        return PassThroughUnitOfWork()
    }
    
    override func boxRepository() -> BoxRepository {
        return NullBoxRepository()
    }
    
    override func itemRepository() -> ItemRepository {
        return NullItemRepository()
    }
}
