//
//  PassThroughUnitOfWork.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData
import XCTest

import RelocationManagerServiceDomain

class TestErrorHandler: HandlesError {
    func handle(error: NSError?) {
        if let error = error {
            XCTFail("unexpected error occured: \(error.localizedDescription)")
        } else {
            XCTFail("unexpected error handling invoked")
        }
    }
}

class PassThroughUnitOfWork: UnitOfWork {
    init() {
        super.init(managedObjectContext: NSManagedObjectContext(), errorHandler: TestErrorHandler())
    }
    
    override func execute(closure: () -> ()) {
        closure()
    }
}
