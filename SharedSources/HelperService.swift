//
//  HelperService.swift
//  MultiProcCounter
//
//  Created by Christian Tietze on 22/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Foundation

@objc(ProvidesCounts)
protocol ProvidesCounts {
    func currentCount(reply: ((UInt) -> Void)!)
}

@objc(Listener)
protocol Listener {
    func updateTicker(tick: Int)
}
