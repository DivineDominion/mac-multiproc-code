//
//  NonNilStringValueTransformer.swift
//  RelocationManager
//
//  Created by Christian Tietze on 13/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

@objc(NonNilStringValueTransformer)
public class NonNilStringValueTransformer: NSValueTransformer {
    override public func transformedValue(value: AnyObject?) -> AnyObject? {
        if value == nil {
            return ""
        }
        
        return value
    }
}