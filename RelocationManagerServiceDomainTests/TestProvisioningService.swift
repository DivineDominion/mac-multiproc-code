//
//  TestProvisioningService.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class TestProvisioningService: ProvisioningService {
    override func provisionItem(title: String, inBox box: Box) { }
    
    var provisionedBoxTitle: String?
    var provisionedBoxCapacity: Int?
    var didProvisionBox = false
    override func provisionBox(title: String, capacity: BoxCapacity) {
        provisionedBoxTitle = title
        provisionedBoxCapacity = capacity.rawValue
        didProvisionBox = true
    }
}