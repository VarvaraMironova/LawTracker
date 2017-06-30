//
//  LTConvocationModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/23/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTConvocationModel: LTEntityModel {
    @NSManaged var number       : String
    @NSManaged var current      : Bool
    
    @NSManaged var initiators   : NSMutableSet
    @NSManaged var laws         : NSMutableSet
    @NSManaged var committees   : NSMutableSet
    
    class func convocationWithNumber(_ number: String) -> LTConvocationModel? {
        let predicate = NSPredicate(format:"number == %@", number)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LTConvocationModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest)) as! [LTConvocationModel]! {
            if models.count > 0 {
                return models.first!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    class func currentConvocation() -> LTConvocationModel? {
        let predicate = NSPredicate(format:"current == %@", true as CVarArg)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LTConvocationModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest)) as! [LTConvocationModel]! {
            if models.count > 0 {
                return models.first!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    class func convocations() -> [LTConvocationModel] {
        let predicate = NSPredicate(value: true)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LTConvocationModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest)) as? [LTConvocationModel] {
            return models
        } else {
            return []
        }
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    override init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        super.init(dictionary: dictionary, context: context, entityName: entityName)
        
        if let number = dictionary[Keys.number] as? String {
            self.number = number
        } else if let number = dictionary[Keys.number] as? Int {
            self.number = "\(number)"
        }
        
        if let current = dictionary[Keys.current] as? Bool {
            self.current = current
        }
    } 

}
