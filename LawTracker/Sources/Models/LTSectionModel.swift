//
//  LTSectionModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation

class LTSectionModel: NSObject {
    var entities  : [LTEntityModel]!
    
    var changes = [LTNewsModel]()
    var filters = [LTFilterCellModel]()
    var title   = String()
    
    var state     : LTState!
    
    override init() {
        super.init()
        
        self.entities = [LTEntityModel]()
    }
    
    init(entities: [LTEntityModel]) {
        super.init()
        
        self.entities = entities
        var titles = [String]()
        for entity in entities {
            if let billModel = entity as? LTLawModel {
                titles.append(billModel.number)
            } else {
                titles.append(entity.title)
            }
        }
        
        self.title = titles.joinWithSeparator("\n")
    }
    
    func newsModelWithEntity(entity: LTEntityModel) -> LTNewsModel? {
        return self.changes.filter(){ $0.entity == entity }.first
    }
}