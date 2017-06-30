//
//  LTMenuTableViewCell.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/11/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTMenuTableViewCell: UITableViewCell {
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {

    }
    
    func fill(_ string: String) {
        titleLabel.text = string
        titleLabel.fit()
    }

}
