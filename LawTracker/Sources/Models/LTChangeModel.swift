//
//  LTChangeModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation
import CoreData

class LTChangeModel: NSManagedObject  {
    struct Keys {
        static let date = "date"
        static let text = "text"
        static let law  = "law"
    }
    
    @NSManaged var date : NSDate
    @NSManaged var text : String
    @NSManaged var law  : LTLawModel
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName("LTChangeModel", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        if let dateString = dictionary[Keys.date] as! String! {
            if let date = dateString.date()! as NSDate! {
                self.date = date
            }
            
        }
        
        self.text = dictionary[Keys.text] as! String
        if let lawID = dictionary[Keys.law] as! String! {
            if let lawModel = LTLawModel.modelWithID(lawID, entityName:"LTLawModel") as! LTLawModel! {
                self.law = lawModel
            } else {
                print ("NoBill")
                //there is no law with lawID so, make request to server
                
            }
        }
    }
}
