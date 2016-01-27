//
//  LTSectionModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation

class LTSectionModel: NSObject {
    var title   : String!
    var changes = [LTChangeModel]()
    
    init(title: String!) {
        super.init()
        
        self.title = title
    }
}