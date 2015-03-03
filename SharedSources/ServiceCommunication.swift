//
//  ServiceCommunication.swift
//  RelocationManager
//
//  Created by Christian Tietze on 12/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

@objc(ManagesBoxesAndItems)
public protocol ManagesBoxesAndItems {
    func provisionBox(label: String, capacity: Int)
    func provisionItem(title: String)
    func removeBox(boxIdentifier: IntegerId)
    func removeItem(itemIdentifier: IntegerId, fromBoxIdentifier boxIdentifier: IntegerId)
}

@objc(UsesBoxesAndItems)
public protocol UsesBoxesAndItems {
    func receiveBox(boxData: NSDictionary)
    func receiveItem(itemData: NSDictionary)
    
    func allowAddingItems()
    func forbidAddingItems()
}