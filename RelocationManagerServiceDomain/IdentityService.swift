//
//  IdentityService.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class IdentityService {
    let boxRepository: BoxRepository
    let itemRepository: ItemRepository
    
    public init(boxRepository: BoxRepository, itemRepository: ItemRepository) {
        self.boxRepository = boxRepository
        self.itemRepository = itemRepository
    }
    
    public func nextBoxId() -> BoxId {
        return boxRepository.nextId()
    }
    
    public func nextItemId() -> ItemId {
        return itemRepository.nextId()
    }
}
