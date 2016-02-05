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
                    LTClient.sharedInstance().downloadInitiatorTypes({ (success, error) -> Void in
                        
                    })
                }
            }
        }
        
        if let committeeID = dictionary[Keys.committee] as? Int {
            if let committeeModel = LTCommitteeModel.modelWithID("\(committeeID)", entityName:"LTCommitteeModel") as! LTCommitteeModel! {
                self.committee = committeeModel
            } else {
                LTClient.sharedInstance().getCommitteeWithId("\(committeeID)"){committee, success, error in
                    if success {
                        self.committee = committee
                    } else {
                        //notify observers with error
                    }
                }
            }
        }
    }
    
    func storeDeputies(deputies: [Int]) {
        for deputyId in deputies {
            if let initiatorModel = LTInitiatorModel.modelWithID("\(deputyId)", entityName:"LTInitiatorModel") as! LTInitiatorModel! {
                self.addValueForKey(initiatorModel, key: Keys.initiators)
            } else {
                LTClient.sharedInstance().getInitiatorWithId("\(deputyId)"){initiator, success, error in
                    if success {
                        self.addValueForKey(initiator, key: Keys.initiators)
                    } else {
                        //notify observers with error
                    }
                }
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
    
}
