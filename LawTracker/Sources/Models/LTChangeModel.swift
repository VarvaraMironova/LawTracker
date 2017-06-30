//
//  LTChangeModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation
import CoreData

class LTChangeModel: LTEntityModel  {
    struct Keys {
        static let status       = "status"
        static let law          = "bill"
        static let changeDate   = "date"
        static let billModel    = "billModel"
    }
    
    @NSManaged var date : Date
    @NSManaged dynamic var law  : LTLawModel
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "LTChangeModel", in: context)!
        super.init(entity: entity, insertInto: context)
        
        if let date = dictionary[Keys.changeDate] as? Date {
            self.date = date
        }
        
        if let title = dictionary[Keys.status] as? String {
            self.title = title
        }
        
        if let billModel = dictionary[Keys.billModel] as? LTLawModel {
            self.law = billModel
        }
        
        if let id = dictionary[Keys.id] as? String {
            self.id = id
        }
    }
    
    class func changesForDate(_ date: Date) -> [LTChangeModel]? {
        let predicate = NSPredicate(format:"date == %@", date as CVarArg)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LTChangeModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.fetch(fetchRequest)) as? [LTChangeModel] {
            return models.count > 0 ? models : nil
        } else {
            return nil
        }
    }
    
}
