//
//  Endpoint.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa

public class Endpoint: NSObject {
    
    let manageBoxes: ManageBoxes
    let manageItems: ManageItems
    
    convenience override init() {
        self.init(manageBoxes: ManageBoxes(), manageItems: ManageItems())
    }
    
    public init(manageBoxes: ManageBoxes, manageItems: ManageItems) {
        self.manageBoxes = manageBoxes
        self.manageItems = manageItems
    }
}

extension Endpoint: ManagesBoxesAndItems {
    
    public func orderBox(label: String, capacity: Int) {
        manageBoxes.orderBox(label, capacity: capacity)
    }
    
    public func distributeItem(title: String) {
        manageItems.distributeItem(title)
    }
    
    public func removeBox(#boxIdentifier: IntegerId) {
        manageBoxes.removeBox(boxIdentifier)
    }
    
    public func removeItem(#itemIdentifier: IntegerId, fromBoxWithIdentifier boxIdentifier: IntegerId) {
        manageItems.removeItem(itemIdentifier, fromBoxIdentifier: boxIdentifier)
    }
}
