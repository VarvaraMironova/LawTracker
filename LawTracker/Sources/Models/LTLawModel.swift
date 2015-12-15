//
//  LTLawModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/14/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

struct LTLawModel {
    var number          : String!
    var name            : String!
    var changes         : [LTChangeModel]!
    var presentationDate: NSDate!
    var initializers    : [String]!
    var mainCommettee   : String!
    var commettees      : [String]!
    var url             : NSURL!
    
    init(dictionary: [String: AnyObject]) {
        if let number = dictionary["number"] as? String {
            self.number = number
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let changes = dictionary["changes"] as? [LTChangeModel] {
            self.changes = changes
        }
        
        
    }

}
