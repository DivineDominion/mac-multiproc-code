//
//  PersistentStack.swift
//  RelocationManagerServiceDomain
//
//  Created by Christian Tietze on 16.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa
import CoreData

public let kDefaultModelName: String = "RelocationManager"
let kErrorDomain = "de.christiantietze.RelocationManager.Service"

public class PersistentStack: NSObject {
    let storeType = NSSQLiteStoreType
    let storeURL: NSURL
    let modelURL: NSURL
    let errorHandler: HandlesError

    public var managedObjectContext: NSManagedObjectContext?
    
    // TODO forbid init()
    
    public init(storeURL: NSURL, modelURL: NSURL, errorHandler: HandlesError) {
        self.storeURL = storeURL
        self.modelURL = modelURL
        self.errorHandler = errorHandler
        
        super.init()
        
        self.setupManagedObjectContext()
    }
    
    func setupManagedObjectContext() {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        self.managedObjectContext = managedObjectContext
    }
    
    /// Optional attribute because file operation could fail.
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var error: NSError? = nil
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let storeOptions = self.defaultStoreOptions()
        var store = coordinator!.addPersistentStoreWithType(self.storeType, configuration: nil, URL: self.storeURL, options: storeOptions, error: &error)
        
        if store == nil {
            let error = wrapError(error, message: "Failed to initialize the application's saved data", reason: "There was an error creating or loading the application's saved data.")
            self.errorHandler.handle(error)
            
            return nil
        }
        
        return coordinator
    }()
    
    /// Required attribute because it's fatal if the `managedObjectModel` cannot be loaded.
    public lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(kDefaultModelName, withExtension: "mom")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    
    // MARK: - Core Data Saving and Undo support
    
    public func objectContextWillSave() {
        // TODO: update creation/modification dates
    }
    
    public func save() {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if let moc = self.managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
            }
            
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                let error = wrapError(error, message: "Failed to save to data store")
                errorHandler.handle(error)
            }
        }
    }
    
    public func undoManager() -> NSUndoManager? {
        if let moc = self.managedObjectContext {
            return moc.undoManager
        }
        
        return nil
    }
    
    public func defaultStoreOptions() -> [String: String] {
        let opts = [String: String]()
        return opts
    }
    
    /// Save changes in the application's managed object context before the application terminates.
    public func saveToTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        if managedObjectContext == nil {
            return .TerminateNow
        }
        
        let moc = managedObjectContext!
        
        if !moc.commitEditing() {
            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
            return .TerminateCancel
        }
        
        if !moc.hasChanges {
            return .TerminateNow
        }
        
        var error: NSError? = nil
        if !moc.save(&error) {
            let error = wrapError(error, message: "Failed to save to data store")
            errorHandler.handle(error)
            
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(error)
            if (result) {
                return .TerminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButtonWithTitle(quitButton)
            alert.addButtonWithTitle(cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                return .TerminateCancel
            }
        }
        return .TerminateNow
    }
}
