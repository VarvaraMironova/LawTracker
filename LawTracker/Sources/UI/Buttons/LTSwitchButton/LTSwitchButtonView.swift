//
//  LTSwitchButtonView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/18/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTSwitchButtonView: UIView {
    @IBOutlet var headerLabel       : UILabel!
    @IBOutlet var switchImageView   : UIImageView!
    @IBOutlet var backgroundView    : UIView!
    
    var selectedImageName           : String!
    var deselectedImageName         : String!
    
    func filtersSet(_ set: Bool) {
        switchImageView.isHidden = !set
    }
    
    weak var rootView: UIView!
    
    class func switchButtonView(_ rootView: UIView, title: String, selectedImageName: String, deselectedImageName: String) -> LTSwitchButtonView {
        let switchButtonView = Bundle.main.loadNibNamed("LTSwitchButtonView", owner: self, options: nil)?.first as! LTSwitchButtonView
        switchButtonView.headerLabel.text = title
        var frame = rootView.frame as CGRect
        frame.origin = CGPoint.zero;
        switchButtonView.frame = frame;
        switchButtonView.selectedImageName = selectedImageName
        switchButtonView.deselectedImageName = deselectedImageName
        
        rootView.addSubview(switchButtonView)
        switchButtonView.rootView = rootView
        
        return switchButtonView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerLabel.font = headerLabel.font.screenProportionalFont()
    }
    
    func setOn(_ on: Bool) {
        if on {
            backgroundView.backgroundColor = UIColor.white
            headerLabel.textColor = UIColor(red: 61.0/255.0, green: 29.0/255.0, blue: 92.0/255.0, alpha: 1.0)
            switchImageView.image = UIImage(named: selectedImageName)
        } else {
            backgroundView.backgroundColor = UIColor(red: 236.0/255.0, green: 233.0/255.0, blue: 239.0/255.0, alpha: 1.0)
            headerLabel.textColor = UIColor.darkGray
            switchImageView.image = UIImage(named: deselectedImageName)
        }
    }

}
