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
    @NSManaged var initialisers     : NSMutableSet
    @NSManaged var committee        : LTCommitteeModel
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        super.init(dictionary: dictionary, context: context, entityName: entityName)
        
        self.url = dictionary[Keys.url] as! String
        
        if let dateString = dictionary[Keys.date] as! String! {
            self.presentationDate = dateString.date()
        }
        
        if let initialisersArray = dictionary[Keys.initialisers] as! [String]! {
            storeInitialisers(initialisersArray)
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
    
    func storeInitialisers(initialisers: [String]) {
        for initialiserId in initialisers {
            if let initialiserModel = LTInitialiserModel.modelWithID(initialiserId, entityName:"LTInitialiserModel") as! LTInitialiserModel! {
                addValueForKey(initialiserModel, key: Keys.initialisers)
            } else {
                LTClient.sharedInstance().getInitialiserWithId(initialiserId){initialiser, success, error in
                    if success {
                        self.addValueForKey(initialiser, key: Keys.initialisers)
                    } else {
                        //notify observers with error
                    }
                }
            }
        }
    }
    
}
