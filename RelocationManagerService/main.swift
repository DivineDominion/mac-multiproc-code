//
//  main.swift
//  MultiProcCounter
//
//  Created by Christian Tietze on 22/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa

if let dependencies = Dependencies().setUp() {
    NSRunLoop.currentRunLoop().run()
}

// TODO present failure when store wasn't set up and setUp() didn't work
