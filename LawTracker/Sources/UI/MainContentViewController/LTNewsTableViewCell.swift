//
//  LTNewsTableViewCell.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTNewsTableViewCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var newsLabel: UILabel!
    
    func fillWithModel(model: LTChangeModel) {
        dateLabel.text = model.date.string()
        newsLabel.text = model.text
        newsLabel.fit()
    }
    
    func getHeight() -> CGFloat {
        return CGRectGetHeight(dateLabel.frame) + CGRectGetHeight(newsLabel.frame)
    }

}
