//
//  LTSelectAllButton.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/1/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTSelectAllButton: UIButton {
    var view    : LTSelectAllButtonView!
    var on: Bool! = false {
        didSet {
            isSelected = on
            if let selectAllButtonView = view as LTSelectAllButtonView! {
                selectAllButtonView.setOn(on)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        view = LTSelectAllButtonView.selectAllButtonView(self, selectedImageName: "checkboxOn", deselectedImageName: "checkboxOff", selectedTitle: "Скасувати виділення", deselectedTitle: "Вибрати всі")
            
        view.setOn(on)
    }

}
