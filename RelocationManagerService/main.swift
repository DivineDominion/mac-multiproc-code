//
//  main.swift
//  MultiProcCounter
//
//  Created by Christian Tietze on 22/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa

if let dependencies = Dependencies().setUp() {
    // Actually run the service code (and never return)
    NSRunLoop.currentRunLoop().run()
} else {
    NSLog("Couldn't start the XPC service")
    exit(EXIT_FAILURE)
}
