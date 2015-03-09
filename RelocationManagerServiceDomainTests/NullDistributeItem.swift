//
//  NullDistributeItem.swift
//  RelocationManager
//
//  Created by Christian Tietze on 09/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class NullDistributeItem: DistributeItem {
    convenience init() {
        self.init(boxRepository: NullBoxRepository(), provisioningService: NullProvisioningService())
    }
}
