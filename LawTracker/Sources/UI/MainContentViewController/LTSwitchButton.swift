//
//  LTSwitchButton.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

enum LTState: Int {
    case LTButtonOff = 0
    case LTButtonOn = 1
}

class LTSwitchButton: UIButton {
    
    var on: Bool! {
        didSet {
            selected = on
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel!.font = titleLabel!.font.screenProportionalFont()
    }
    
}
