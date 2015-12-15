//
//  LTFilterTableViewCell.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTFilterTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    
    func fillWithModel(model: LTSectionModel) {
        titleLabel.text = model.title
        
        titleLabel.fit()
    }
}
