//
//  UnitOfWork.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

public class UnitOfWork {
    
    let managedObjectContext: NSManagedObjectContext
    let errorHandler: HandlesError
    
    public init(managedObjectContext: NSManagedObjectContext, errorHandler: HandlesError) {
        self.managedObjectContext = managedObjectContext
        self.errorHandler = errorHandler
    }

    /// Synchronously execute `closure` to sequentially perform transactions.
    public func execute(closure: () -> ()) {
        var error: NSError? = nil
        var success = false
        
        managedObjectContext.performBlock {
            closure()
            
            success = self.managedObjectContext.save(&error)
        }
        
        if !success {
            errorHandler.handle(error)
        }
    }
}
