//
//  IdGenerator.swift
//  RelocationManager
//
//  Created by Christian Tietze on 09/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation
import Security

public protocol GeneratesIntegerId {
    func integerId() -> IntegerId
}

struct DefaultIntegerIdGenerator: GeneratesIntegerId {
    func integerId() -> IntegerId {
        arc4random_stir()
        var urandom: UInt64
        urandom = (UInt64(arc4random()) << 32) | UInt64(arc4random())
        
        var random: IntegerId = (IntegerId) (urandom & 0x7FFFFFFFFFFFFFFF);
        
        return random
    }
}

struct IdGenerator<Id: Identifiable> {
    let integerIdGenerator: GeneratesIntegerId
    let integerIdIsTaken: (IntegerId) -> Bool
    
    func nextId() -> Id {
        return Id(unusedIntegerId())
    }
    
    func unusedIntegerId() -> IntegerId {
        var identifier: IntegerId
        
        do {
            identifier = integerId()
        } while integerIdIsTaken(identifier)
        
        return identifier
    }
    
    func integerId() -> IntegerId {
        return integerIdGenerator.integerId()
    }
}
