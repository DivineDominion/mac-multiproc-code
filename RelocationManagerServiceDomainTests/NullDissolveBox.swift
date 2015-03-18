//
//  NullDissolveBox.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class NullDissolveBox: DissolveBox {
    convenience init() {
        self.init(boxRepository: NullBoxRepository(), itemRepository: NullItemRepository(), distributionService: NullDistributeItem())
    }
    
    override func dissolve(boxId: BoxId) { }
}