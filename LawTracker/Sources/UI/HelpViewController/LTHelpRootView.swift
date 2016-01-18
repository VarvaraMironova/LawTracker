//
//  LTHelpRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/15/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTHelpRootView: UIView {
    @IBOutlet var headerView    : UIView!
    @IBOutlet var logogImageView: UIImageView!
    @IBOutlet var closeButton   : UIButton!
    @IBOutlet var scrollView    : UIScrollView!
    @IBOutlet var contentView   : UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.contentSize = contentView.bounds.size
    }
    
}