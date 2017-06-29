//
//  LTSelectAllButtonView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/1/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTSelectAllButtonView: UIView {
    @IBOutlet var checkboxImageView : UIImageView!
    @IBOutlet var titleLabel        : UILabel!
    
    var selectedImageName           : String!
    var deselectedImageName         : String!
    
    var selectedTitle               : String!
    var deselectedTitle             : String!
    
    weak var rootView: UIView!
    
    func setOn(_ on: Bool) {
        if on {
            checkboxImageView.image = UIImage(named:selectedImageName)
            titleLabel.text = selectedTitle
        } else {
            checkboxImageView.image = UIImage(named:deselectedImageName)
            titleLabel.text = deselectedTitle
        }
    }
    
    class func selectAllButtonView(_ rootView: UIView, selectedImageName: String, deselectedImageName: String, selectedTitle: String, deselectedTitle: String) -> LTSelectAllButtonView {
        let selectAllButtonView = Bundle.main.loadNibNamed("LTSelectAllButtonView", owner: self, options: nil)?.first as! LTSelectAllButtonView
        selectAllButtonView.selectedTitle = selectedTitle
        selectAllButtonView.deselectedTitle = deselectedTitle
        selectAllButtonView.selectedImageName = selectedImageName
        selectAllButtonView.deselectedImageName = deselectedImageName
        
        var frame = rootView.frame as CGRect
        frame.origin = CGPoint.zero;
        selectAllButtonView.frame = frame;
        
        rootView.addSubview(selectAllButtonView)
        selectAllButtonView.rootView = rootView
        
        return selectAllButtonView
    }

}
