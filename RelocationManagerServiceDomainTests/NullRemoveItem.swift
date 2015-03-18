//
//  NullRemoveItem.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class NullRemoveItem: RemoveItem {
    init() {
        super.init(itemRepository: NullItemRepository())
    }
    
    override func remove(itemId: ItemId, fromBox boxId: BoxId) { }
}
