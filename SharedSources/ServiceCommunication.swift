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
    func orderBox(label: String, capacity: Int)
    func distributeItem(title: String)
    func removeBox(#boxIdentifier: IntegerId)
    func removeItem(#itemIdentifier: IntegerId, fromBoxWithIdentifier boxIdentifier: IntegerId)
}

@objc(UsesBoxesAndItems)
public protocol UsesBoxesAndItems {
    func apply(eventRepresentation: NSDictionary)
}
