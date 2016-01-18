//
//  LTInitialiserModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTInitialiserModel: LTEntityModel {
    @NSManaged var laws     : NSMutableSet
    @NSManaged var isDeputy : Bool
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        super.init(dictionary: dictionary, context: context, entityName: entityName)
        
        if let deputy = dictionary[Keys.deputy] as! String! {
            self.isDeputy = deputy == "1"
        }
    }
    
}
