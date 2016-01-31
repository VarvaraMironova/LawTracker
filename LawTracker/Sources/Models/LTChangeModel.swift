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
    }
    
    @NSManaged var date         : NSDate
    @NSManaged var law          : LTLawModel
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName("LTChangeModel", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        date = NSDate()
        
        if let title = dictionary[Keys.status] as? String {
            self.title = title
        }
        
        if let lawNumber = dictionary[Keys.law] as? String {
            if let lawModel = LTLawModel.lawWithNumber(lawNumber) as! LTLawModel! {
                self.law = lawModel
            } else {
                //there is no law with lawID so, make request to server
                LTClient.sharedInstance().getLawWithId(lawNumber) {law, success, error in
                    if success {
                        self.law = law
                    } else {
                        print("cannot find law with number\(lawNumber)")
                    }
                }
            }
        }
        
        self.id = date.string("yyyy-MM-dddd")+law.id
    }
}
