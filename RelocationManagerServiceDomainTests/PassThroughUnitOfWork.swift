//
//  PassThroughUnitOfWork.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

import RelocationManagerServiceDomain

class PassThroughUnitOfWork: UnitOfWork {
    init() {
        super.init(managedObjectContext: NSManagedObjectContext())
    }
    
    override func execute(closure: () -> ()) {
        closure()
    }
}
