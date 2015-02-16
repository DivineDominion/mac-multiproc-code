//
//  CreateBox.swift
//  RelocationManager
//
//  Created by Christian Tietze on 16/02/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

import Cocoa

public class RunModal {
    public init() { }
    
    public func runModalForWindow(window: NSWindow) {
        NSApp.runModalForWindow(window)
    }
    
    public func stopModal() {
        NSApp.stopModal()
    }
}

public class CreateBox: HandlesBoxCreationEvents {
    
    public lazy var modalizer: RunModal = {
        return RunModal()
    }()
    
    public lazy var windowController: BoxCreationWindowController! = {
        
        let controller = BoxCreationWindowController()
        controller.loadWindow()
        controller.eventHandler = self
        
        return controller
    }()
    
    var orderService: ManagesBoxesAndItems!
    
    public init(orderService: ManagesBoxesAndItems) {
        self.orderService = orderService
    }
    
    public func showDialog() {
        windowController.showWindow(self)
        
        if let window = windowController.window {
            window.makeKeyAndOrderFront(self)
            modalizer.runModalForWindow(window)
        }
    }
    
    public func order(boxOrder: BoxOrder) {
        orderService.provisionBox(boxOrder.label, capacity: boxOrder.capacity)
    }
    
    public func cancel() {
        modalizer.stopModal()
    }
}