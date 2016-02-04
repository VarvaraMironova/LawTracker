//
//  LTSwitchButton.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTSwitchButton: UIButton {
    var switchButtonView    : LTSwitchButtonView!
    var on: Bool! = false {
        didSet {
            selected = on
            if let switchButtonView = switchButtonView as LTSwitchButtonView! {
                switchButtonView.setOn(on)
            }
        }
    }
    
    var filtersSet: Bool! {
        didSet {
            switchButtonView.filtersSet(filtersSet)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let titleLabel = titleLabel as UILabel! {
            if let text = titleLabel.text as String! {
                switchButtonView = LTSwitchButtonView.switchButtonView(self, title: text, selectedImageName: "filterSet", deselectedImageName: "filterNotSet")
                titleLabel.text = ""
                
                switchButtonView.setOn(on)
            }
        }
    }
    
}
