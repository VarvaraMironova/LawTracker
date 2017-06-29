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
    
    func fillWithModel(_ model: LTFilterCellModel) {
        let entity = model.entity
        filtered = model.selected
        titleLabel.text = entity?.title
        
        if let committee = entity as? LTCommitteeModel {
            if committee.expired {
                isUserInteractionEnabled = false
                titleLabel.textColor = UIColor.darkGray
            }
        }
    }
    
    
}
