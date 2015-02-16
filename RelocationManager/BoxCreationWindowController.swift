//
//  BoxCreationWindowController.swift
//  RelocationManager
//
//  Created by Christian Tietze on 16/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa

public protocol HandlesBoxCreationEvents {
    func order(boxOrder: BoxOrder)
    func cancel()
}

let kBoxCreationWindowControllerNibName = "BoxCreationWindowController"

public class BoxCreationWindowController: NSWindowController, NSWindowDelegate {

    public var eventHandler: HandlesBoxCreationEvents?
    
    /// Initialize using the default Nib
    public override convenience init() {
        self.init(windowNibName: kBoxCreationWindowControllerNibName)
    }
    
    public override func loadWindow() {
        super.loadWindow()
        
        window?.level = kCGModalPanelWindowLevelKey
    }
    
    
    // MARK: Buttons

    @IBOutlet public var orderButton: NSButton!
    
    @IBAction public func order(sender: AnyObject) {
        if let eventHandler = eventHandler {
            let boxOrder = boxOrderFromForm()
            eventHandler.order(boxOrder)
        }
    }
    
    func boxOrderFromForm() -> BoxOrder {
        return BoxOrder(label: boxLabel(), capacity: boxCapacity())
    }
    
    
    @IBOutlet public var cancelButton: NSButton!
    
    @IBAction public func cancel(sender: AnyObject) {
        self.close()
    }
    
    public func windowWillClose(notification: NSNotification) {
        if let eventHandler = eventHandler {
            eventHandler.cancel()
        }
    }
    
    
    // MARK: Data Input 
    
    @IBOutlet public var capacityComboBox: NSComboBox!
    
    func boxCapacity() -> Int {
        return capacityComboBox.integerValue
    }
    
    
    @IBOutlet public var boxLabelTextField: NSTextField!
    
    func boxLabel() -> String {
        let labelText = boxLabelTextField.stringValue
        
        if labelText == "" {
            return "New Box"
        }
        
        return labelText
    }
    
    
}
