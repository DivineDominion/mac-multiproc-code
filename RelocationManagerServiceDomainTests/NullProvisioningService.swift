//
//  NullProvisioningService.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class NullProvisioningService: ProvisioningService {
    convenience init() {
        self.init(boxRepository: NullBoxRepository(), itemRepository: NullItemRepository())
    }
}
