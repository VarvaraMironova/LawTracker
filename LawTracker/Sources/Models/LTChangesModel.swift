//
//  LTChangesModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/6/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

class LTChangesModel: NSObject {
    var changes         : [LTSectionModel] = []
    var filtersIsApplied: Bool!
    var date            : NSDate!
    
    init(changes: [LTSectionModel], filtersIsApplied: Bool, date: NSDate) {
        super.init()
        
        self.changes = changes
        self.filtersIsApplied = filtersIsApplied
        self.date = date
    }
    
    func addModel(model: LTSectionModel) {
        changes.append(model)
    }
    
    func count() -> Int {
        return changes.count
    }
}
