//
//  LTSearchTableViewCell.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/8/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTSearchTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

    func fill(title: String) {
        titleLabel.text = title
    }
    
}
