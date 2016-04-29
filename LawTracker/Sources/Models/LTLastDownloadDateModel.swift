//
//  LTLastDownloadDateModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 4/7/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTLastDownloadDateModel: NSManagedObject {
    @NSManaged var date : String
    @NSManaged var time : String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(date: String, time: String, context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName("LTLastDownloadDateModel", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.date = date
        self.time = time
    }
    
    class func timeForDate(date: String) -> LTLastDownloadDateModel? {
        let predicate = NSPredicate(format:"date == %@", date)
        let fetchRequest = NSFetchRequest(entityName: "LTLastDownloadDateModel")
        fetchRequest.predicate = predicate
        if let models = (try? CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(fetchRequest)) as? [LTLastDownloadDateModel] {
            if models.count > 0 {
                return models.first!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

}
