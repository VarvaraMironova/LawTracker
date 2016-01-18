//
//  CoreDataStackManager.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/27/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation
import CoreData

private let kVTSQLFileName  = "LawTracker.sqlite"
private let kVTMomdFileName = "LawTracker"

class CoreDataStackManager {
    
    // MARK: - Shared Instance
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        
        return Static.instance
    }
    
    // MARK: - The Core Data stack. The code has been moved, unaltered, from the AppDelegate.
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(kVTMomdFileName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(kVTSQLFileName)
        
        print("sqlite path: \(url.path!)")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            abort()
        }
        
        return coordinator
    }()
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func delete(object:NSManagedObject) {
        managedObjectContext.deleteObject(object)
    }
    
    func storeLawsFromArray(laws: [NSDictionary], completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for lawArray in laws {
                _ = LTLawModel(dictionary: lawArray as! [String : AnyObject], context: self.managedObjectContext, entityName:"LTLawModel")
            }
            
            self.saveContext()
            
            completionHandler(finished: true)
        }
    }
    
    func storeCommitteesFromArray(committees: [NSDictionary], completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for committeeArray in committees {
                _ = LTCommitteeModel(dictionary: committeeArray as! [String : AnyObject], context: self.managedObjectContext, entityName:"LTCommitteeModel")
            }
            
            self.saveContext()
            
            completionHandler(finished: true)
        }
        
    }
    
    func storeInitialisersFromArray(initialisers: [NSDictionary], completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for initialiserArray in initialisers {
            _ = LTInitialiserModel(dictionary: initialiserArray as! [String : AnyObject], context: self.managedObjectContext, entityName:"LTInitialiserModel")
            }
            
            self.saveContext()
            
            completionHandler(finished: true)}
        
    }
    
    func storeChangesFromArray(changes: [NSDictionary], completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for changeArray in changes {
            _ = LTChangeModel(dictionary: changeArray as! [String : AnyObject], context: self.managedObjectContext)
            }
            
            self.saveContext()
            
            completionHandler(finished: true)}
        
    }
}
