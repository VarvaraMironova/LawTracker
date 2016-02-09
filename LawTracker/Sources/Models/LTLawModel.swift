//
//  LTLawModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/14/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import CoreData

class LTLawModel: LTEntityModel {
    @NSManaged var number           : String
    @NSManaged var presentationDate : NSDate?
    @NSManaged var url              : String
    
    @NSManaged var changes          : NSMutableSet
    @NSManaged var initiators       : NSMutableSet
    
    @NSManaged var convocation      : LTConvocationModel
    @NSManaged var committee        : LTCommitteeModel
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        super.init(dictionary: dictionary, context: context, entityName: entityName)
        
        if let url = dictionary[Keys.url] as? String {
            self.url = url
        }
        
        if let convocationModel = dictionary[Keys.convocation] as? LTConvocationModel {
            self.convocation = convocationModel
        }
        
        if let dateString = dictionary[Keys.date] as? String {
            if let date = dateString.date() as NSDate! {
                self.presentationDate = date
            }
        }
        
        if let number = dictionary[Keys.number] as? String {
            self.number = number
        }
        
        if let typeID = dictionary[Keys.type] as? String {
            if typeID == "deputy" {
                if let deputiesArray = dictionary[Keys.initiators] as? [Int] {
                    storeDeputies(deputiesArray)
                }
            } else {
                if let initiatorModel = LTInitiatorModel.modelWithID(typeID, entityName:"LTInitiatorModel") as! LTInitiatorModel! {
                    self.addValueForKey(initiatorModel, key: Keys.initiators)
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                        LTClient.sharedInstance().getInitiatorTypeWithId(typeID){initiatorModel, success, error in
                            if success {
                                dispatch_async(dispatch_get_main_queue()){
                                    if let initiatorModel = initiatorModel as LTInitiatorModel! {
                                        self.addValueForKey(initiatorModel, key: Keys.initiators)
                                    } else {
                                        print("Cannot get info about initiator type \(typeID)")
                                    }
                                }
                            } else {
                                print("Cannot get info about initiator type \(typeID)")
                            }
                        }
                    }
                }
            }
        }
        
        if let committeeID = dictionary[Keys.committee] as? Int {
            let committeeIDString = "\(committeeID)"
            if let committeeModel = LTCommitteeModel.modelWithID(committeeIDString, entityName:"LTCommitteeModel") as! LTCommitteeModel! {
                self.committee = committeeModel
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                    LTClient.sharedInstance().getCommitteeWithId(committeeIDString){committee, success, error in
                        if success {
                            dispatch_async(dispatch_get_main_queue()){
                                if let committee = committee as LTCommitteeModel! {
                                    self.committee = committee
                                } else {
                                    print("Cannot get info about committee with id \(committeeID)")
                                }
                            }
                        } else {
                            print("Cannot get info about committee with id \(committeeID)")
                        }
                    }
                }
            }
        }
    }
    
    func storeDeputies(deputies: [Int]) {
        for deputyId in deputies {
            let idString : String = "\(deputyId)"
            if let initiatorModel = LTInitiatorModel.modelWithID(idString, entityName:"LTInitiatorModel") as! LTInitiatorModel! {
                self.addValueForKey(initiatorModel, key: Keys.initiators)
            } else {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
//                    LTClient.sharedInstance().getInitiatorWithId(idString){initiator, success, error in
//                        if success {
//                            dispatch_async(dispatch_get_main_queue()){
//                                if let initiator = initiator as LTInitiatorModel! {
//                                    self.addValueForKey(initiator, key: Keys.initiators)
//                                } else {
//                                    print("Cannot get info about deputy with id \(idString)")
//                                }
//                            }
//                        } else {
//                            print("Cannot get info about deputy with id \(idString)")
//                        }
//                    }
//                }
            }
        }
    }
    
    class func lawWithNumber(number: String) -> LTEntityModel? {
        let predicate = NSPredicate(format:"number == %@", number)
        let fetchRequest = NSFetchRequest(entityName: "LTLawModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as? [LTLawModel] {
            if models.count > 0 {
                return models.first!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    class func changesForLaw(number: String) -> NSMutableSet? {
        let predicate = NSPredicate(format:"number == %@", number)
        let fetchRequest = NSFetchRequest(entityName: "LTLawModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as? [LTLawModel] {
            if models.count > 0 {
                let changes = models.first!.changes
                for change in changes {
                    print("DATE =", change.date)
                }
                
                return changes
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
}
