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
            isSelected = on
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
    
    //MARK:- Public
    func setFilterImage(_ key: LTType) {
        CoreDataStackManager.coreDataQueue().async {[unowned self] in
            if let filteredEntities = LTEntityModel.filteredEntities(key) as [LTEntityModel]! {
                DispatchQueue.main.async {
                    self.filtersSet = filteredEntities.count > 0
                }
            } else {
                DispatchQueue.main.async {
                    self.filtersSet = false
                }
            }
        }
    }
    
}
