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
        static let id           = "id"
        static let number       = "number"
        static let title        = "title"
        static let url          = "url"
        static let date         = "filing_date"
        static let changes      = "changes"
        static let initiators   = "initiators"
        static let laws         = "laws"
        static let deputy       = "isDeputy"
        static let committee    = "committee"
        static let starts       = "starts"
        static let ends         = "ends"
        static let type         = "initiator_type"
        static let convocations = "convocations"
        static let convocation  = "convocation"
        static let current      = "current"
        static let persons      = "persons"
    }
    
    @NSManaged var id    : String
    @NSManaged var title : String
    
    @NSManaged var filterSet : Bool
    
    var entityName: String!
    
    class func modelWithID(id: String, entityName: String) -> LTEntityModel? {
        let predicate = NSPredicate(format:"id == %@", id)
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as? [LTEntityModel] {
            if models.count > 0 {
                return models.first!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    class func filteredEntities(key: LTType)  -> [LTEntityModel]? {
        let predicate = NSPredicate(format:"filterSet == %@", true)
        var entityName = String()
        switch key {
        case .byLaws:
            entityName = "LTLawModel"
            break
            
        case .byInitiators:
            entityName = "LTInitiatorModel"
            break
            
        case .byCommittees:
            entityName = "LTCommitteeModel"
            break
        }
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as? [LTEntityModel] {
            return models
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
        
        if let id = dictionary[Keys.id] as? String {
            self.id = id
        } else if let id = dictionary[Keys.id] as? Int {
            self.id = "\(id)"
        }
        
        if let title = dictionary[Keys.title] as? String {
            self.title = title
        }
    }
    
    // MARK: - Public
    func update(dictionary: [String : AnyObject]) {
        
    }
    
    func addValueForKey(value: AnyObject, key: String) {
        if deleted {
            return
        }
        
        mutableSetValueForKey(key).addObject(value)
    }
}
