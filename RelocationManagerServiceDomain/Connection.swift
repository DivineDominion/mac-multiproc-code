//
//  Connection.swift
//  RelocationManager
//
//  Created by Christian Tietze on 04/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public class Connection {
    let endpoint: Endpoint
    let client: UsesBoxesAndItems
    
    public init(endpoint: Endpoint, client: UsesBoxesAndItems) {
        self.endpoint = endpoint
        self.client = client
    }
    
    public func send(event: ClientEvent) {
        client.apply(event.dictionaryRepresentation)
    }
}
