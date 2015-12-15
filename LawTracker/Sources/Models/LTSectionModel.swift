//
//  LTSectionModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation

struct LTSectionModel {
    var title: String!
    var changes : [LTChangeModel]!
    
    init(title: String!, changes: [LTChangeModel]!) {
        self.title = title
        self.changes = changes
    }
}