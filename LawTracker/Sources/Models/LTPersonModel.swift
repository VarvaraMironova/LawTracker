//
//  LTPersonModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/18/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData

struct LTPersonModel {
    struct Keys {
        static let id           = "id"
        static let firstName    = "first_name"
        static let secondName   = "second_name"
        static let lastName     = "last_name"
        static let fullName     = "full_name"
        static let convocations = "convocations"
    }
    
    var id         : String!
    var firstName  : String!
    var secondName : String!
    var lastName   : String!
    var fullName   : String!
    
    var initiator  : LTInitiatorModel!
    
    var convocations  = NSMutableSet()
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext, entityName: String) {
        if let id = dictionary[Keys.id] as? String {
            self.id = id
        } else if let id = dictionary[Keys.id] as? Int {
            self.id = "\(id)"
        }
        
        if let firstName = dictionary[Keys.firstName] as? String {
            self.firstName = firstName
        }
        
        if let secondName = dictionary[Keys.secondName] as? String {
            self.secondName = secondName
        }
        
        if let lastName = dictionary[Keys.lastName] as? String {
            self.lastName = lastName
        }
        
        if let fullName = dictionary[Keys.fullName] as? String {
            self.fullName = fullName
        }
        
        //save convocations
        if let convocationsArray = dictionary[Keys.convocations] as? [String] {
            for convocation in convocationsArray {
                if let convocationModel = LTConvocationModel.convocationWithNumber(convocation) {
                    convocations.addObject(convocationModel)
                } else {
                    //download convocation with number = convocation
                }
            }
        }
        
        //create initiatorModel
        if let initiatorModel = LTInitiatorModel.modelWithID(id, entityName:"LTInitiatorModel") as? LTInitiatorModel {
            initiator = initiatorModel
        } else {
            let dictionary = ["id":id, "title":fullName, "isDeputy":"true", "convocations":convocations]
            initiator = LTInitiatorModel(dictionary: dictionary, context: context, entityName: "LTInitiatorModel")
        }
    }
}
