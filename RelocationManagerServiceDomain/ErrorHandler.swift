//
//  ErrorHandler.swift
//  RelocationManager
//
//  Created by Christian Tietze on 18/03/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

public protocol HandlesError {
    func handle(error: NSError?)
}

public class ErrorHandler: HandlesError {
    public func handle(error: NSError?) {
        if let error = error {
            NSLog("Error occured: ", error.localizedDescription)
        }
    }
}
