//
//  CoreDataManager.swift
//  RotimaticMobile
//
//  Created by Basawaraj on 27/10/15.
//  Copyright © 2015 Cuelogic. All rights reserved.
//

import UIKit

import CoreData

class CoreDataManager: NSObject {

    let kStoreName = "ChatUI.sqlite"
    let kModmName = "ChatUI"
    
    var _managedObjectContext: NSManagedObjectContext?
    var _managedObjectModel: NSManagedObjectModel?
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    // MARK: Shared Instance
    class var shared: CoreDataManager {
        
        get {
            struct Static {
                static var instance : CoreDataManager? = nil
                static var token : dispatch_once_t = 0
            }
            dispatch_once(&Static.token) { Static.instance = CoreDataManager() }
            
            return Static.instance!
        }
        
    }
    
    
    func initialize(){
        
        self.managedObjectContext
        
    }
    
    // MARK: Core Data stack
    
    var managedObjectContext: NSManagedObjectContext {
        
        if _managedObjectContext == nil {
            let coordinator = self.persistentStoreCoordinator
            _managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            _managedObjectContext!.persistentStoreCoordinator = coordinator
        }
        
        return _managedObjectContext!
        
    }
    
    
    
    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
        
        if _managedObjectModel == nil {
            let modelURL = NSBundle.mainBundle().URLForResource(kModmName, withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        }
        
        return _managedObjectModel!
        
    }
    
    
    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(kStoreName)
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        return coordinator
        
    }
    
    
    
    // MARK: - Fetches
    func executeFetchRequest(request: NSFetchRequest, completionHandler:(results: Array<AnyObject>?, error: NSError?) -> Void)-> () {
        
            var fetchError:NSError?
            var results:Array<AnyObject>?
            do {
                results = try self.managedObjectContext.executeFetchRequest(request)
            } catch let error as NSError {
                fetchError = error  
                results = nil
            }
            if let error = fetchError {
                print("Warning!! \(error.description)")
            }
            
            completionHandler(results: results, error: fetchError)
        
    }
    
    // MARK: - Delete Object
    func executeDeleteRequest(results: Array<AnyObject>?, failureHandler:(error: NSError?) -> Void) {
        
        for userInfo in results! {
            self.managedObjectContext.deleteObject(userInfo as! NSManagedObject)
        }
        self.save { (error) -> Void in
            if error != nil {
                failureHandler(error: error)
            }
        }
        
    }
    
    
    
    //MARK: - Save Methods
    
    func save(failureHandler:(error: NSError?) -> Void) {
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                failureHandler(error: nserror)
            }
        }
        
    }


    //MARK: - Utilities
    func deleteEntity(object: NSManagedObject)-> () {
        
        object.managedObjectContext! .deleteObject(object)
        
    }
    
    //MARK: - Application's Documents directory
    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: NSURL {
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        print("Path - \(urls[urls.endIndex-1])")
        return urls[urls.endIndex-1] as NSURL
        
    }
    
    
    func databaseOptions() -> Dictionary <String,Bool> {
        
        var options =  Dictionary<String,Bool>()
        options[NSMigratePersistentStoresAutomaticallyOption] = true
        options[NSInferMappingModelAutomaticallyOption] = true
        return options
        
    }
    


}
