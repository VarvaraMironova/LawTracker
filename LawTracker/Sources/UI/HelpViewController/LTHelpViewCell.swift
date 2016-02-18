//
//  LTHelpViewCell.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/30/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTHelpViewCell: UICollectionViewCell {
    @IBOutlet var backArrowImageView    : UIImageView!
    @IBOutlet var forwardArrowImageView : UIImageView!
    @IBOutlet var contentImageView      : UIImageView!
    
    func fillWithModel(model: [String]) {
        if .Portrait == UIApplication.sharedApplication().statusBarOrientation {
            contentImageView.image = UIImage(named: model.first!)
        } else {
            contentImageView.image = UIImage(named: model.last!)
        }
    }
}
