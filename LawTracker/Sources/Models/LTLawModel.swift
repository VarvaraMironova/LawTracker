//
//  LTLawModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/14/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import CoreData

class LTLawModel: LTEntityModel {
    @NSManaged var presentationDate : NSDate?
    @NSManaged var url              : String
    @NSManaged var changes          : NSMutableSet
    @NSManaged var initiators       : NSMutableSet
    @NSManaged var committee        : LTCommitteeModel
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        super.init(dictionary: dictionary, context: context, entityName: entityName)
        
        self.url = dictionary[Keys.url] as! String
        
        if let dateString = dictionary[Keys.date] as! String! {
            if let date = dateString.date() as NSDate! {
                self.presentationDate = date
            }
        }
        
        if let typeID = dictionary[Keys.type] as! String! {
            if typeID == "deputy" {
                if let initiatorsArray = dictionary[Keys.initiators] as! [String]! {
                    storeInitiators(initiatorsArray)
                }
            } else {
                if let initiatorModel = LTInitiatorModel.modelWithID(typeID, entityName:"LTInitiatorModel") as! LTInitiatorModel! {
                    self.addValueForKey(initiatorModel, key: Keys.initiators)
                } else {
                    if let typeModel = LTInitiatorTypeModel.modelWithID(typeID, entityName:"LTInitiatorTypeModel") as! LTInitiatorTypeModel! {
                        let initiatorModel = LTInitiatorModel(id:typeModel.id, title: typeModel.title, isDeputy: false, persons: NSMutableSet(), context: context, entityName: "LTInitiatorModel")
                        self.addValueForKey(initiatorModel, key: Keys.initiators)
                    } else {
                        //get type with typeID from server!
                    }
                }
            }
        }
        
        if let committeeID = dictionary[Keys.committee] as! String! {
            if let committeeModel = LTCommitteeModel.modelWithID(committeeID, entityName:"LTCommitteeModel") as! LTCommitteeModel! {
                self.committee = committeeModel
            } else {
                LTClient.sharedInstance().getCommitteeWithId(committeeID){committee, success, error in
                    if success {
                        self.committee = committee
                    } else {
                        //notify observers with error
                    }
                }
            }
        }
    }
    
    func storeInitiators(persons: [String]) {
        for personId in persons {
            if let personModel = LTPersonModel.modelWithID(personId, entityName:"LTPersonModel") as! LTPersonModel! {
                self.addValueForKey(personModel.initiator, key: Keys.initiators)
            } else {
                LTClient.sharedInstance().getPersonWithId(personId){person, success, error in
                    if success {
                        self.addValueForKey(person.initiator, key: Keys.initiators)
                    } else {
                        //notify observers with error
                    }
                }
            }
        }
    }
    
}
