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
    var filtersApplied  : Bool = false
    var date            : Date!
    var type            : LTType!
    
    override init() {
        super.init()
        
        self.changes = []
        self.date = Date()
    }
    
    init(changes: [LTSectionModel], type: LTType, filtersApplied: Bool, date: Date) {
        super.init()
        
        self.changes = changes
        self.filtersApplied = filtersApplied
        self.date = date
        self.type = type
    }
    
    func addModel(_ model: LTSectionModel) {
        changes.append(model)
    }
    
    func count() -> Int {
        return changes.count
    }
    
    func sectionWithEntities(_ entities:[LTEntityModel]) -> LTSectionModel? {
        return changes.filter(){ $0.entities == entities }.first
    }
    
}
