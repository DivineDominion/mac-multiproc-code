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
    
    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    /// Synchronously execute `closure` to sequentially perform transactions.
    public func execute(closure: () -> ()) {
        managedObjectContext.performBlock(closure)
    }
}
