//
//  DispatchClient.swift
//  RelocationManager
//
//  Created by Christian Tietze on 20/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class DispatchClient {
    
    let client: UsesBoxesAndItems
    
    public init(client: UsesBoxesAndItems) {
        self.client = client
    }
    
    public func send(event: ClientEvent) {
        client.apply(event.dictionaryRepresentation)
    }
}
