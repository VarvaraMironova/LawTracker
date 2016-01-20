//
//  LTCommitteeModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

class LTCommitteeModel: LTEntityModel {
    @NSManaged var url    : String
    @NSManaged var starts : NSDate
    @NSManaged var ends   : NSDate
    @NSManaged var laws   : NSMutableSet
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        super.init(dictionary: dictionary, context: context, entityName: entityName)
        
        url = dictionary[Keys.url] as! String
        
        if let startsString = dictionary[Keys.starts] as? String {
            if let startsDate = startsString.date() as NSDate! {
                starts = startsDate
            }
        }
        
        if let endsString = dictionary[Keys.ends] as? String {
            if let endsDate = endsString.date() as NSDate! {
                ends = endsDate
            }
        }
    }
}
