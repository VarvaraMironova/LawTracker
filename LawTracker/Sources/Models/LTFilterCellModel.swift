//
//  LTFilterCellModel
//  LawTracker
//
//  Created by Varvara Mironova on 1/26/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

class LTFilterCellModel: NSObject {
    var entity: LTEntityModel!
    var selected: Bool!
    
    init(entity: LTEntityModel) {
        super.init()
        
        self.entity = entity
        self.selected = entity.filterSet
    }
    
}