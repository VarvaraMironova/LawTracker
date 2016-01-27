//
//  LTFilterModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/26/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

class LTFilterModel: NSObject {
    var entity: LTEntityModel!
    var selected: Bool!
    
    init(entity: LTEntityModel, selected: Bool) {
        super.init()
        
        self.entity = entity
        self.selected = selected
    }
    
}