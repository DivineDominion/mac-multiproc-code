//
//  TestIntegerIdGenerator.swift
//  RelocationManager
//
//  Created by Christian Tietze on 09/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

import RelocationManagerServiceDomain

class TestIntegerIdGenerator : NSObject, GeneratesIntegerId {
    let firstAttempt: IntegerId = 1234
    let secondAttempt: IntegerId = 5678
    var callCount = 0
    
    func integerId() -> IntegerId {
        let identifier = (callCount == 0 ? firstAttempt : secondAttempt)
        
        callCount++
        
        return identifier
    }
}
