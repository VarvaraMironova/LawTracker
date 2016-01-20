//
//  LTEntityModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTEntityModel: NSManagedObject {
    struct Keys {
        static let id         = "id"
        static let title      = "title"
        static let url        = "url"
        static let date       = "filing_date"
        static let changes    = "changes"
        static let initiators = "initiators"
        static let laws       = "laws"
        static let deputy     = "isDeputy"
        static let committee  = "committee"
        static let starts     = "starts"
        static let ends       = "ends"
    }
    
    @NSManaged var id    : String
    @NSManaged var title : String
    
    var entityName: String!
    
    class func modelWithID(id: String, entityName: String) -> LTEntityModel? {
        let predicate = NSPredicate(format:"id == %@", id)
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as! [LTEntityModel]! {
            return models.first!
        } else {
            return nil
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.entityName = entityName
        id = dictionary[Keys.id] as! String
        title = dictionary[Keys.title] as! String
    }
    
    func addValueForKey(value: LTEntityModel, key: String) {
        if deleted {
            return
        }
        
        mutableSetValueForKey(key).addObject(value)
    }
}
