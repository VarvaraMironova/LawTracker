//
//  LTHelpRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/15/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTHelpRootView: UIView {
    @IBOutlet var headerView        : UIView!
    @IBOutlet var closeButton       : UIButton!
    @IBOutlet var helpCollectionView: UICollectionView!
    
    @IBOutlet var scrollBarContainer: UIView!
    @IBOutlet var scrollBar         : [UIView]!
    
    var selectedIndex   : Int = 0 {
        didSet {
            if oldValue != selectedIndex {
                let deselectedItem = scrollBar.filter() { $0.tag == oldValue }.first
                if let view = deselectedItem as UIView! {
                    view.backgroundColor = UIColor.lightGrayColor()
                    view.transform = CGAffineTransformIdentity
                }
                
                let selectedItem = scrollBar.filter() { $0.tag == selectedIndex }.first
                if let view = selectedItem as UIView! {
                    view.backgroundColor = UIColor.whiteColor()
                    view.transform = CGAffineTransformMake(1.2, 0, 0, 1.2, 0, 0)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in scrollBar {
            let layer = view.layer
            layer.cornerRadius = 5.0
            layer.masksToBounds = true
        }
    }
    
}
