//
//  LTHelpViewCell.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/30/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTHelpViewCell: UICollectionViewCell {
    @IBOutlet var topImageView          : UIImageView!
    @IBOutlet var topTextView           : UITextView!
    @IBOutlet var bottomImageView       : UIImageView!
    @IBOutlet var bottomTextView        : UITextView!
    @IBOutlet var backArrowImageView    : UIImageView!
    @IBOutlet var forwardArrowImageView : UIImageView!
    
    func fill(topText: String, topImage: String, bottomText: String, bottomImage: String, index: Int) {
        topImageView.image = UIImage(named: topImage)
        bottomImageView.image = UIImage(named: bottomImage)
        topTextView.text = topText
        bottomTextView.text = bottomText
        
        switch index {
        case 0:
            backArrowImageView.hidden = true
            forwardArrowImageView.hidden = false
            
            break
            
        case 3:
            backArrowImageView.hidden = false
            forwardArrowImageView.hidden = true
            
            break
            
        default:
            backArrowImageView.hidden = false
            forwardArrowImageView.hidden = false
            
            break
        }
    }
}
