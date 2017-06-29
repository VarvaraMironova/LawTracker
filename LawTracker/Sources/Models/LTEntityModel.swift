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
    
    class func modelWithID(_ id: String, entityName: String) -> LTEntityModel? {
        let predicate = NSPredicate(format:"id == %@", id)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest)) as? [LTEntityModel] {
            if models.count > 0 {
                return models.first!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    class func filteredEntities(_ key: LTType)  -> [LTEntityModel]? {
        let predicate = NSPredicate(format:"filterSet == %@", true as CVarArg)
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest)) as? [LTEntityModel] {
            return models
        } else {
            return nil
        }
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: entityName, in: context)!
        super.init(entity: entity, insertInto: context)
        
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
    
    func addValueForKey(_ value: AnyObject, key: String) {
        if isDeleted {
            return
        }
        
        mutableSetValue(forKey: key).add(value)
    }
}
