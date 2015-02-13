//
//  BoxManagementWindowController.swift
//  RelocationManager
//
//  Created by Christian Tietze on 10/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa

public let kBoxManagementWindowControllerNibName = "BoxManagementWindowController"

public class BoxManagementWindowController: NSWindowController {

    @IBOutlet public var boxViewController: BoxViewController!
    
    /// Initialize using the default Nib
    public override convenience init() {
        self.init(windowNibName: kBoxManagementWindowControllerNibName)
    }
}
