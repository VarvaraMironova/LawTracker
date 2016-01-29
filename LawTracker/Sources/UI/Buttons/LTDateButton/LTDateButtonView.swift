//
//  LTDateButtonView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/28/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTDateButtonView: UIView {
    @IBOutlet var titleLabel     : UILabel!
    @IBOutlet var rightImageView : UIImageView!
    @IBOutlet var leftImageView  : UIImageView!
    
    weak var rootView: UIView!
    
    class func LTDateButtonView(rootView: UIView) -> LTDateButtonView {
        let LTDateButtonView = NSBundle.mainBundle().loadNibNamed("LTDateButtonView", owner: self, options: nil).first as! LTSwitchButtonView
        var frame = rootView.frame as CGRect
        frame.origin = CGPointZero;
        LTDateButtonView.frame = frame;
        
        rootView.addSubview(LTDateButtonView)
        LTDateButtonView.rootView = rootView
        
        return LTDateButtonView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

}
