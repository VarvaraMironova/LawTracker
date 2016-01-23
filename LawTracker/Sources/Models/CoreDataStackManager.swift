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
    
    func storeConvocations(convocations: [NSDictionary], completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for convocationArray in convocations {
                _ = LTConvocationModel(dictionary: convocationArray as! [String : AnyObject], context: self.managedObjectContext, entityName:"LTConvocationModel")
            }
            
            self.saveContext()
            
            completionHandler(finished: true)
        }
    }
    
    func storeLaws(laws: [NSDictionary], convocation: String, completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for lawArray in laws {
                if var mutableLawArray = lawArray as? [String : AnyObject] {
                    mutableLawArray["convocation"] = convocation
                    _ = LTLawModel(dictionary: mutableLawArray, context: self.managedObjectContext, entityName:"LTLawModel")
                }
            }
            
            self.saveContext()
            
            completionHandler(finished: true)
        }
    }
    
    func storeCommittees(committees: [NSDictionary], convocation: String, completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for committeeArray in committees {
                if var mutableCommitteeArray = committeeArray as? [String : AnyObject] {
                    mutableCommitteeArray["convocation"] = convocation
                    _ = LTCommitteeModel(dictionary: mutableCommitteeArray, context: self.managedObjectContext, entityName:"LTCommitteeModel")
                }
            }
            
            self.saveContext()
            
            completionHandler(finished: true)
        }
    }
    
    func storeInitiatorTypes(types: [String : AnyObject], completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for (key, value) in types {
                let type = ["id": key, "title": value]
                _ = LTInitiatorTypeModel(dictionary: type, context: self.managedObjectContext, entityName:"LTInitiatorTypeModel")
            }
            
            self.saveContext()
            
            completionHandler(finished: true)
        }
    }
    
    func storePersons(persons: [NSDictionary], completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for person in persons {
            _ = LTPersonModel(dictionary: person as! [String : AnyObject], context: self.managedObjectContext, entityName:"LTPersonModel")
            }
            
            self.saveContext()
            
            completionHandler(finished: true)
        }
    }
    
    func storeChanges(changes: [NSDictionary], completionHandler: (finished: Bool) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            for changeArray in changes {
                _ = LTChangeModel(dictionary: changeArray as! [String : AnyObject], context: self.managedObjectContext)
            }
            
            self.saveContext()
            
            completionHandler(finished: true)
        }
    }
    
    func clearEntity(entityName: String, completionHandler:(success: Bool, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            let fetchRequest = NSFetchRequest(entityName: entityName)
            fetchRequest.includesPropertyValues = false
            
            do {
                if let results = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                    for result in results {
                        self.managedObjectContext.deleteObject(result)
                    }
                }
                
                self.saveContext()
                
                completionHandler(success: true, error: nil)
            } catch let error as NSError {
                completionHandler(success: false, error: error)
            }
        }
    }
}
