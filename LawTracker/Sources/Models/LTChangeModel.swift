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
        
        if let id = dictionary[Keys.id] as? String {
            self.id = id
        }
        
        if let lawNumber = dictionary[Keys.law] as? String {
            if let lawModel = LTLawModel.lawWithNumber(lawNumber) as LTLawModel! {
                self.law = lawModel
            } else {
                //there is no law with lawID so, make request to server
                let queue = CoreDataStackManager.coreDataQueue()
                dispatch_async(queue){
                    LTClient.sharedInstance().getLawWithId(lawNumber) {success, error in
                        if success {
                            dispatch_async(CoreDataStackManager.coreDataQueue()){
                                if let law = LTLawModel.lawWithNumber(lawNumber) as LTLawModel! {
                                    self.law = law
                                } else {
                                    print("Cannot find law with number \(lawNumber)")
                                }
                            }
                        } else {
                            print("Cannot find law with number \(lawNumber)")
                        }
                    }
                }
            }
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
}
