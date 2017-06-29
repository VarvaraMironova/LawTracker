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
private let kLTQueueName    = "CoreDataQueue"

class CoreDataStackManager {

    // MARK: - Shared Instance
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = { CoreDataStackManager() }()
        }
        
        return Static.instance
    }
    
    class func coreDataQueue() -> DispatchQueue {
        struct Static {
            static var onceToken: Int = 0
            static var instance = { DispatchQueue(label: kLTQueueName, attributes: []) }()
        }
        
        return Static.instance
    }
    
    // MARK: - The Core Data stack. The code has been moved, unaltered, from the AppDelegate.
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: kVTMomdFileName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(kVTSQLFileName)
        
        print("sqlite path: \(url.path)")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            abort()
        }
        
        return coordinator
    }()
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
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
    
    func delete(_ object:NSManagedObject) {
        managedObjectContext.delete(object)
    }
    
    func storeConvocations(_ convocations: [[String: AnyObject]], completionHandler: @escaping (_ finished: Bool) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        queue.async {
            for convocationArray in convocations {
                var convocationID = String()
                if let id = convocationArray["id"] as? String {
                    convocationID = id
                } else if let id = convocationArray["id"] as? Int {
                    convocationID = "\(id)"
                }
                
                if nil == LTConvocationModel.modelWithID(convocationID, entityName: "LTConvocationModel") {
                    _ = LTConvocationModel(dictionary: convocationArray, context: self.managedObjectContext, entityName:"LTConvocationModel")
                }
            }
            
            self.saveContext()
            
            completionHandler(true)
        }
    }
    
    func storeLaws(_ laws: [[String: AnyObject]], convocation: String, completionHandler: @escaping (_ finished: Bool) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        queue.async { [unowned self, weak context = managedObjectContext] in
            for lawArray in laws {
                var lawId = String()
                if let id = lawArray["id"] as? String {
                    lawId = id
                } else if let id = lawArray["id"] as? Int {
                    lawId = "\(id)"
                }
                
                if nil == LTLawModel.modelWithID(lawId, entityName: "LTLawModel") {
                    var mutableLawArray = lawArray
                    mutableLawArray["convocation"] = convocation as AnyObject
                    
                    //store initiators
                    self.storeInitiators(mutableLawArray) { (result, finished) in
                        if finished {
                            mutableLawArray["initiatorModels"] = result as AnyObject
                            
                            //storeCommittees
                            if let committeeID = mutableLawArray["committee"] as? Int {
                                let committeeIDString = "\(committeeID)"
                                if let committeeModel = LTCommitteeModel.modelWithID(committeeIDString, entityName:"LTCommitteeModel") as! LTCommitteeModel! {
                                    mutableLawArray["committeeModel"] = committeeModel
                                } else {
                                    LTClient.sharedInstance().getCommitteeWithId(committeeIDString){success, error in
                                        if success {
                                            CoreDataStackManager.coreDataQueue().async{
                                                if let committee = LTCommitteeModel.modelWithID(committeeIDString, entityName: "LTCommitteeModel") as? LTCommitteeModel! {
                                                    mutableLawArray["committeeModel"] = committee
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    _ = LTLawModel(dictionary: mutableLawArray, context: context!, entityName:"LTLawModel")
                }
            }
            
            self.saveContext()
            
            completionHandler(true)
        }
    }
    
    func storeCommittees(_ committees: [[String: AnyObject]], convocation: String, completionHandler: @escaping (_ finished: Bool) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        queue.async {[unowned self, weak context = managedObjectContext] in
            for committeeArray in committees {
                var committeeId = String()
                if let id = committeeArray["id"] as? String {
                    committeeId = id
                } else if let id = committeeArray["id"] as? Int {
                    committeeId = "\(id)"
                }
                
                if nil == LTCommitteeModel.modelWithID(committeeId, entityName: "LTCommitteeModel") {
                    var mutableCommitteeArray = committeeArray
                    mutableCommitteeArray["convocation"] = convocation as AnyObject
                    _ = LTCommitteeModel(dictionary: mutableCommitteeArray, context: context!, entityName:"LTCommitteeModel")
                }
            }
            
            self.saveContext()
            
            completionHandler(true)
        }
    }
    
    func storeInitiatorTypes(_ types: [String : AnyObject], completionHandler: @escaping (_ finished: Bool) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        queue.async {[unowned self, weak context = managedObjectContext] in
            for (key, value) in types {
                if nil == LTInitiatorTypeModel.modelWithID(key, entityName: "LTInitiatorTypeModel") {
                    let type = ["id": key, "title": value] as [String : Any]
                    _ = LTInitiatorTypeModel(dictionary: type as [String : AnyObject], context: context!, entityName:"LTInitiatorTypeModel")
                }
            }
            
            self.saveContext()
            
            completionHandler(true)
        }
    }
    
    func storePersons(_ persons: [[String: AnyObject]], completionHandler: @escaping (_ finished: Bool) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        queue.async {[unowned self, weak context = managedObjectContext] in
            for person in persons {
            _ = LTPersonModel(dictionary: person, context: context!, entityName:"LTPersonModel")
            }
            
            self.saveContext()
            
            completionHandler(true)
        }
    }
    
    func storeChanges(_ date: Date, changes: [[String: AnyObject]], completionHandler: @escaping (_ finished: Bool) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        queue.async {[unowned self, weak context = managedObjectContext] in
            let dateString = date.string("yyyy-MM-dd")
            for changeArray in changes {
                var changeId = dateString
                if let billID = changeArray["bill"] as? String {
                    changeId += billID
                } else if let billID = changeArray["bill"] as? Int {
                    changeId += "\(billID)"
                }
                
                if nil == LTChangeModel.modelWithID(changeId, entityName: "LTChangeModel") {
                    var mutableChangeArray = changeArray
                    mutableChangeArray["date"] = date as AnyObject
                    mutableChangeArray["id"] = changeId as AnyObject
                    
                    //get lawModel
                    if let lawNumber = mutableChangeArray["bill"] as? String {
                        self.getLawWithNumber(lawNumber) { (result, finished) in
                            mutableChangeArray["billModel"] = result
                            queue.async {
                                _ = LTChangeModel(dictionary: mutableChangeArray, context: context!)
                            }
                        }
                    }
                }
            }
            
            self.saveContext()
            completionHandler(true)
        }
    }
    
    func clearEntity(_ entityName: String, completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        queue.async {[unowned self, weak context = managedObjectContext] in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                if let persistentStoreCoordinator = self.persistentStoreCoordinator  as NSPersistentStoreCoordinator! {
                    try persistentStoreCoordinator.execute(deleteRequest, with: context!)
                    completionHandler(true, nil)
                }
            } catch let error as NSError {
                completionHandler(true, error)
            }
        }
    }
    
    fileprivate func getLawWithNumber(_ lawNumber: String, completionHandler:@escaping (_ result: LTLawModel, _ finished: Bool) -> Void) {
        if let lawModel = LTLawModel.lawWithNumber(lawNumber) as LTLawModel! {
            completionHandler(lawModel, true)
        } else {
            //there is no law with lawID so, make request to server
            LTClient.sharedInstance().getLawWithId(lawNumber) {success, error in
                if success {
                    CoreDataStackManager.coreDataQueue().async{
                        if let law = LTLawModel.lawWithNumber(lawNumber) as LTLawModel! {
                            completionHandler(law, true)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func storeInitiators(_ array: [String : AnyObject], completionHandler:(_ result: [LTInitiatorModel], _ finished: Bool) -> Void) {
        var initiatorModels = [LTInitiatorModel]()
        let queue = CoreDataStackManager.coreDataQueue()
        if let typeID = array["initiator_type"] as? String {
            if typeID == "deputy" {
                if let deputiesArray = array["initiators"] as? [Int] {
                    for deputyId in deputiesArray {
                        let idString : String = "\(deputyId)"
                        if let initiatorModel = LTInitiatorModel.modelWithID(idString, entityName:"LTInitiatorModel") as! LTInitiatorModel! {
                            initiatorModels.append(initiatorModel)
                        } else {
                            LTClient.sharedInstance().getInitiatorWithId(idString){success, error in
                                if success {
                                    queue.async{
                                        if let initiator = LTInitiatorModel.modelWithID(idString, entityName: "LTInitiatorModel") as? LTInitiatorModel! {
                                            initiatorModels.append(initiator)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if let initiatorModel = LTInitiatorModel.modelWithID(typeID, entityName:"LTInitiatorModel") as! LTInitiatorModel! {
                    initiatorModels.append(initiatorModel)
                } else {
                    LTClient.sharedInstance().getInitiatorTypeWithId(typeID){success, error in
                        if success {
                            queue.async{
                                if let initiatorModel = LTInitiatorModel.modelWithID(typeID, entityName: "LTInitiatorModel") as? LTInitiatorModel! {
                                    initiatorModels.append(initiatorModel)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        completionHandler(initiatorModels, true)
    }
    
    func synchronized(_ lock: AnyObject, closure:() -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

}
