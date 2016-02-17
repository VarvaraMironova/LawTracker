//
//  LTNewsModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/15/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import  Foundation

class LTNewsModel: NSObject {
    var billName: String!
    var status : String!
    var entity : LTChangeModel!
    
    var state  : LTState!
    
    init(entity: LTChangeModel, type: LTType) {
        super.init()
        self.entity = entity
        switch type {
        case .byLaws:
            self.status = entity.title
            self.billName = entity.law.title
            
            break
            
        default:
            self.status = entity.title
            let law = entity.law
            self.billName = "№ " + law.number + ". " + law.title
            
            break
        }
    }
}
