//
//  LTSectionModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation

class LTSectionModel: NSObject {
    var entities  = [LTEntityModel]()
    lazy var filtersSet: Bool = {[unowned self] in
        var filtersSet = false
        for entity in self.entities {
            if entity.filterSet {
                filtersSet = true
            }
        }
        
        return filtersSet
    }()
    
    var changes = [LTNewsModel]()
    var filters = [LTFilterCellModel]()
    var title   = String()
    
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
        
        self.title = titles.joined(separator: "\n")
    }
    
    func newsModelWithEntity(_ entity: LTEntityModel) -> LTNewsModel? {
        return self.changes.filter(){ $0.entity == entity }.first
    }
    
    func addModel(_ model: LTNewsModel) {
        changes.append(model)
    }
    
    func count() -> Int {
        return changes.count
    }
}
