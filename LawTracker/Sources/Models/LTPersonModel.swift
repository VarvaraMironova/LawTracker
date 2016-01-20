//
//  LTPersonModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/18/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTPersonModel: LTEntityModel {
    struct Keys {
        static let firstName    = "first_name"
        static let secondName   = "second_name"
        static let lastName     = "last_name"
        static let title        = "full_name"
        static let convocations = "convocations"
    }
    
    @NSManaged var firstName  : String
    @NSManaged var secondName : String
    @NSManaged var lastName   : String
    
    @NSManaged var initiator  : LTInitiatorModel
    
    @NSManaged var convocations  : NSMutableSet
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        // Core Data
        super.init(dictionary: dictionary, context: context, entityName: entityName)
        
        if let firstName = dictionary[Keys.firstName] as? String {
            self.firstName = firstName
        }
        
        if let secondName = dictionary[Keys.secondName] as? String {
            self.secondName = secondName
        }
        
        if let lastName = dictionary[Keys.lastName] as? String {
            self.lastName = lastName
        }
        
//        if let fullName = dictionary[Keys.title] as? String {
//            self.title = fullName
//        }
        
        //create initiatorModel
        if let initiatorModel = LTInitiatorModel.modelWithID(id, entityName:"LTInitiatorModel") as! LTInitiatorModel! {
            initiator = initiatorModel
        } else {
            let name = firstName + " " + secondName + " " + lastName
            initiator = LTInitiatorModel(id:id, title: name, isDeputy: true, persons: ([self]), context:context, entityName: "LTInitiatorModel")
        }
        
        //save convocations
//        if let convocationsArray = dictionary[Keys.convocations] as! [String]! {
//            for convocation in convocationsArray {
//                self.addValueForKey(convocation, key:Keys.convocations)
//            }
//        }
    }
    
//    class func modelWithID(id: String) -> LTPersonModel? {
//        let predicate = NSPredicate(format:"id == %@", id)
//        let fetchRequest = NSFetchRequest(entityName: "LTPersonModel")
//        fetchRequest.predicate = predicate
//        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as! [LTPersonModel]! {
//            return models.first!
//        } else {
//            return nil
//        }
//    }

}
