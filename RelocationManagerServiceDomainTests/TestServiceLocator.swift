//
//  TestServiceLocator.swift
//  RelocationManager
//
//  Created by Christian Tietze on 17/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class TestServiceLocator: ServiceLocator {
    var testBoxRepository = NullBoxRepository()
    override func boxRepository() -> BoxRepository {
        return testBoxRepository
    }
    
    var testItemRepository = NullItemRepository()
    override func itemRepository() -> ItemRepository {
        return testItemRepository
    }
}
