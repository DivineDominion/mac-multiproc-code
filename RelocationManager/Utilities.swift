//
//  Utilities.swift
//  RelocationManager
//
//  Created by Christian Tietze on 03/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation
import CoreData

func delay(delay: Double, closure: () -> ()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func dispatch_async_main(closure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), closure)
}

func logDetailledErrors(error: NSError) {
    if let detailedErrors: [NSError] = error.userInfo?[NSDetailedErrorsKey] as? [NSError] {
        for detailedError in detailedErrors {
            NSLog("  DetailedError: \(detailedError.userInfo)")
        }
    } else {
        NSLog("  \(error.userInfo)")
    }
}

func wrapError(error: NSError?, # message: String) -> NSError {
    return wrapError(error, message: message, reason: nil)
}

func wrapError(error: NSError?, # message: String, # reason: String?) -> NSError {
    var userInfo: [NSString: AnyObject] = [
        NSLocalizedDescriptionKey: message,
    ]
    
    if let reason = reason {
        userInfo[NSLocalizedFailureReasonErrorKey] = reason
    }
    
    if let underlyingError = error {
        userInfo[NSUnderlyingErrorKey] = error
    }
    
    return NSError(domain: kErrorDomain, code: 999, userInfo: nil)
}