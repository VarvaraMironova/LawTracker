//
//  LTSwitchButtonView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/18/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTSwitchButtonView: UIView {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var switchImageView: UIImageView!
    @IBOutlet var backgroundView: UIView!
    
    func filtersSet(set: Bool) {
        if set {
            switchImageView.image = UIImage(named:"filterSet")
        } else {
            switchImageView.image = UIImage(named:"filterNotSet")
        }
    }
    
    weak var rootView: UIView!
    
    class func switchButtonView(rootView: UIView, title: String) -> LTSwitchButtonView {
        let switchButtonView = NSBundle.mainBundle().loadNibNamed("LTSwitchButtonView", owner: self, options: nil).first as! LTSwitchButtonView
        switchButtonView.headerLabel.text = title
        var frame = rootView.frame as CGRect
        frame.origin = CGPointZero;
        switchButtonView.frame = frame;
        
        rootView.addSubview(switchButtonView)
        switchButtonView.rootView = rootView
        
        return switchButtonView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerLabel.font = headerLabel.font.screenProportionalFont()
    }
    
    func setOn(on: Bool) {
        if on {
            backgroundView.backgroundColor = UIColor.whiteColor()
            headerLabel.textColor = UIColor(red: 61.0/255.0, green: 29.0/255.0, blue: 92.0/255.0, alpha: 1.0)
            switchImageView.hidden = false
        } else {
            backgroundView.backgroundColor = UIColor(red: 236.0/255.0, green: 233.0/255.0, blue: 239.0/255.0, alpha: 1.0)
            headerLabel.textColor = UIColor.darkGrayColor()
            switchImageView.hidden = true
        }
    }

}
