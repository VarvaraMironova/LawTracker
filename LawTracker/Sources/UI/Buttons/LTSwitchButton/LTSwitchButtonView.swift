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
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var switchImageView: UIImageView!
    
    func filtersSet(set: Bool) {
        if set {
            subTitleLabel.text = "Застосовано фільтри!"
        } else {
            subTitleLabel.text = "Фільтри не застосовано!"
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
        subTitleLabel.font = subTitleLabel.font.screenProportionalFont()
    }
    
    func setOn(on: Bool) {
        if on {
            headerLabel.textColor = UIColor(red: 61.0/255.0, green: 29.0/255.0, blue: 92.0/255.0, alpha: 1.0)
            subTitleLabel.hidden = false
            switchImageView.hidden = false
        } else {
            headerLabel.textColor = UIColor.darkGrayColor()
            subTitleLabel.hidden = true
            switchImageView.hidden = true
        }
    }

}
