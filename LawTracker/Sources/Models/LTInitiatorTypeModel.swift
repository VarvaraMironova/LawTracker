//
//  LTInitiatorTypeModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/18/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTInitiatorTypeModel: LTEntityModel {
    @NSManaged var persons : NSMutableSet
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        super.init(dictionary: dictionary, context: context, entityName: entityName)
        
        if id != "deputy" {
            let dictionary = ["id":id, "title":title, "isDeputy":"false", "convocations":NSMutableSet()]
            
            _ = LTInitiatorModel(dictionary: dictionary, context: context, entityName: "LTInitiatorModel")
        }
    }

}
