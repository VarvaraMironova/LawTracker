//
//  LTFilterTableViewCell.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTFilterTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel     : UILabel!
    @IBOutlet var filterImageView: UIImageView!
    
    var filtered : Bool! {
        didSet {
            filterImageView.image = filtered == true ? UIImage(named: "checkboxOn") : UIImage(named: "checkboxOff")
        }
    }
    
    func fillWithModel(model: LTFilterModel) {
        filtered = model.selected
        titleLabel.text = model.entity.title
        
        titleLabel.fit()
    }
}
