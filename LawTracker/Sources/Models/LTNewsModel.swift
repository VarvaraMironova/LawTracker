//
//  LTNewsModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/15/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import  Foundation
import  UIKit

class LTNewsModel: NSObject {
    var billName: String!
    var status  : String!
    var entity  : LTChangeModel!
    
    var state  : LTState = .notLoaded
    
    init(entity: LTChangeModel, type: LTType) {
        super.init()
        
        let bill = entity.law
        self.entity = entity
        self.status = entity.title
        
        switch type {
        case .byLaws:
            self.billName = bill.title
            
            break
            
        default:
            self.billName = "№ " + bill.number + ". " + bill.title
            
            break
        }
    }
}
