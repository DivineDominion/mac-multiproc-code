//
//  ServiceCommunication.swift
//  RelocationManager
//
//  Created by Christian Tietze on 12/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

@objc(ManagesBoxesAndItems)
protocol ManagesBoxesAndItems {
    func provisionBox()
    func provisionItem(boxIdentifier: IntegerId)
    func removeBox(boxIdentifier: IntegerId)
    func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId)
}

@objc(UsesBoxesAndItems)
protocol UsesBoxesAndItems {
    func allowAddingItems()
    func forbidAddingItems()
}