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
    @NSManaged var presentationDate : Date?
    @NSManaged var url              : String
    
    @NSManaged var changes          : NSMutableSet
    @NSManaged var initiators       : NSMutableSet
    
    @NSManaged var convocation      : LTConvocationModel
    @NSManaged var committee        : LTCommitteeModel
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
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
            if let date = dateString.date() as Date! {
                self.presentationDate = date
            }
        }
        
        if let number = dictionary[Keys.number] as? String {
            self.number = number
        }
        
        if let committeeModel = dictionary["committeeModel"] as? LTCommitteeModel {
            self.committee = committeeModel
        }
        
        if let initiatorsModel = dictionary["initiatorModels"] as? [LTInitiatorModel] {
            for initiator in initiatorsModel {
                addValueForKey(initiator, key: Keys.initiators)
            }
        }
    }
    
    class func lawWithNumber(_ number: String) -> LTLawModel? {
        let predicate = NSPredicate(format:"number == %@", number)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LTLawModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest)) as? [LTLawModel] {
            if models.count > 0 {
                return models.first!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    class func changesForLaw(_ number: String) -> NSMutableSet? {
        let predicate = NSPredicate(format:"number == %@", number)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LTLawModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest)) as? [LTLawModel] {
            if models.count > 0 {
                let changes = models.first!.changes
                for change in changes {
                    print("DATE =", (change as AnyObject).date)
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
