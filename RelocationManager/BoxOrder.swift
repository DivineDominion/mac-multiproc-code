//
//  BoxOrder.swift
//  RelocationManager
//
//  Created by Christian Tietze on 16/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

/// Represents a user's request to order a new box.
public struct BoxOrder {
    public let label: String
    public let capacity: Int
    
    public init(label: String, capacity: Int) {
        self.label = label
        self.capacity = capacity
    }
}
