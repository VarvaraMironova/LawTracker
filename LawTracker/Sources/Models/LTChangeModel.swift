//
//  LTChangeModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation

struct LTChangeModel {
    var date        : String
    var description : String
    
    init(date: String, description: String) {
        self.date = date
        self.description = description
    }
}
