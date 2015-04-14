//
//  PrepareConnection.swift
//  RelocationManager
//
//  Created by Christian Tietze on 19/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

class PrepareConnection {
    init() { }
    
    private let endpoint = Endpoint()
    
    private var connection: NSXPCConnection?
    
    func prepare(connection: NSXPCConnection) -> PrepareConnection {
        
        connection.exportedInterface = NSXPCInterface(`withProtocol`: ManagesBoxesAndItems.self)
        connection.exportedObject = endpoint
    
        connection.remoteObjectInterface = NSXPCInterface(`withProtocol`: UsesBoxesAndItems.self)
        self.connection = connection
        
        return self
    }
    
    private var invalidationHandler: (() -> ())?
    
    func onInvalidation(invalidationHandler: () -> ()) -> PrepareConnection {
        
        self.invalidationHandler = invalidationHandler
        
        return self
    }
    
    func build() -> ConnectionController? {
        
        if let connection = connection {
            return buildConnectionController(connection)
        }
        
        return nil
    }
    
    private func buildConnectionController(connection: NSXPCConnection) -> ConnectionController {
        
        if let invalidationHandler = invalidationHandler {
            connection.invalidationHandler = {
                dispatch_async_main {
                    invalidationHandler()
                }
            }
        }
        
        return ConnectionController(connection: Connection(service: connection))
    }

}
