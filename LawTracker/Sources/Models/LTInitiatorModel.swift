//
//  LTInitiatorModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTInitiatorModel: LTEntityModel {
    @NSManaged var isDeputy : Bool
    @NSManaged var persons  : NSMutableSet
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(name: String, isDeputy: Bool, persons: NSMutableSet, context: NSManagedObjectContext, entityName: String) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.isDeputy = isDeputy
        self.persons = persons
    }
    
}
