//
//  ManageBoxesAndItems.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 28.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public class ManageBoxesAndItems {
    public init() { }
    
//    lazy var eventHandler: HandleBoxAndItemModifications! = {
//        let provisioningService = ProvisioningService(repository: ServiceLocator.boxRepository())
//        return HandleBoxAndItemModifications(provisioningService: provisioningService)
//    }()
    
//    lazy var presenter: DisplayBoxesAndItems! = {
//        let service = DisplayBoxesAndItems()
//        return service
//    }()

    lazy var windowController: BoxManagementWindowController! = {
        let controller = BoxManagementWindowController()
        controller.loadWindow()
        // controller.eventHandler = self.eventHandler
        // self.presenter.consumer = controller.itemViewController
        return controller
    }()
    
    public lazy var boxViewController: BoxViewController = {
        return self.windowController.boxViewController
    }()
    
    public func showBoxManagementWindow() {
        displayBoxes()
        showWindow()
    }
    
    func displayBoxes() {
        // TODO: Display initial data
    }

    func showWindow() {
        windowController.showWindow(self)
        windowController.window?.makeKeyAndOrderFront(self)
    }
}
