//
//  LTPersonModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/18/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTPersonModel: NSManagedObject {
    struct Keys {
        static let id         = "id"
        static let title      = "title"
        static let firstName  = "first_name"
        static let secondName = "second_name"
        static let lastName   = "last_name"
        static let type       = "initiator_type"
    }
    
    @NSManaged var id         : String
    @NSManaged var firstName  : String
    @NSManaged var secondName : String
    @NSManaged var lastName   : String
    
    @NSManaged var type       : LTInitiatorTypeModel
    @NSManaged var initiator  : LTInitiatorModel
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.id] as! String
        firstName = dictionary[Keys.firstName] as! String
        secondName = dictionary[Keys.secondName] as! String
        lastName = dictionary[Keys.lastName] as! String
        
        //get typeModel from typeID
        if let typeID = dictionary[Keys.type] as! String! {
            if let typeModel = LTInitiatorTypeModel.modelWithID(typeID, entityName:"LTInitiatorTypeModel") as! LTInitiatorTypeModel! {
                self.type = typeModel
            } else {
                LTClient.sharedInstance().getInitiatorTypeWithId(typeID){type, success, error in
                    if success {
                        self.type = type
                    } else {
                        //notify observers with error
                    }
                }
            }
        }
        
        //create initiatorModel
        if type.title == "Депутат" {
            let name = firstName + " " + secondName + " " + lastName
            initiator = LTInitiatorModel(title: name, isDeputy: true, persons: ([self]), context:context, entityName: "LTInitiatorModel")
        } else {
            let predicate = NSPredicate(format:"title == %@", type.title)
            let fetchRequest = NSFetchRequest(entityName: "LTInitiatorModel")
            fetchRequest.predicate = predicate
            if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as! [LTInitiatorModel]! {
                if models.count > 0 {
                    initiator = models.first!
                } else {
                    initiator = LTInitiatorModel(title: type.title, isDeputy: false, persons: type.persons, context: context, entityName: "LTInitiatorModel")
                }
            } else {
                initiator = LTInitiatorModel(title: type.title, isDeputy: false, persons: type.persons, context: context, entityName: "LTInitiatorModel")
            }
        }
    }
    
    class func modelWithID(id: String) -> LTPersonModel? {
        let predicate = NSPredicate(format:"id == %@", id)
        let fetchRequest = NSFetchRequest(entityName: "LTPersonModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as! [LTPersonModel]! {
            return models.first!
        } else {
            return nil
        }
    }

}
