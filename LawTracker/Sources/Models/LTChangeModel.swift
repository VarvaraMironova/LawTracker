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
    
    @NSManaged var date : NSDate
    @NSManaged dynamic var law  : LTLawModel
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName("LTChangeModel", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        if let date = dictionary[Keys.changeDate] as? NSDate {
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
    
    class func changesForDate(date: NSDate) -> [LTChangeModel]? {
        let predicate = NSPredicate(format:"date == %@", date)
        let fetchRequest = NSFetchRequest(entityName: "LTChangeModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as? [LTChangeModel] {
            return models.count > 0 ? models : nil
        } else {
            return nil
        }
    }
    
    // MARK: - Public
    override func update(dictionary: [String : AnyObject]) {
        super.update(dictionary)
        
        if let date = dictionary[Keys.changeDate] as? NSDate {
            self.date = date
        }
        
        if let title = dictionary[Keys.status] as? String {
            self.title = title
        }
        
        if let billModel = dictionary[Keys.billModel] as? LTLawModel {
            self.law = billModel
        }
    }
    
}
