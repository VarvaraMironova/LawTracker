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
    var filtersApplied  : Bool!
    var date            : NSDate!
    
    override init() {
        super.init()
        
        self.changes = []
        self.filtersApplied = false
        self.date = NSDate()
    }
    
    init(changes: [LTSectionModel], filtersApplied: Bool, date: NSDate) {
        super.init()
        
        self.changes = changes
        self.filtersApplied = filtersApplied
        self.date = date
    }
    
    func addModel(model: LTSectionModel) {
        changes.append(model)
    }
    
    func count() -> Int {
        return changes.count
    }
    
    func sectionWithEntities(entities:[LTEntityModel]) -> LTSectionModel? {
        return changes.filter(){ $0.entities == entities }.first
    }
    
}
