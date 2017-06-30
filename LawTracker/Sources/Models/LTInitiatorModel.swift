//
//  LTInitiatorModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTInitiatorModel: LTEntityModel {
    @NSManaged var isDeputy     : Bool
    @NSManaged var convocations : NSMutableSet
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    override init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        super.init(dictionary: dictionary, context: context, entityName: entityName)
        
        if let isDeputy = dictionary[Keys.deputy] as? String {
            self.isDeputy = isDeputy == "true"
        }
        
        if let convocations = dictionary[Keys.convocations] as? NSMutableSet {
            self.convocations = convocations
        }
    }
    
}
