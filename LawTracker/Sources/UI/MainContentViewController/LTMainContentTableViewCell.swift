//
//  LTMainContentTableViewCell.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTMainContentTableViewCell: UITableViewCell {
    @IBOutlet var newsLabel         : UILabel!
    @IBOutlet var lawNameLabel      : UILabel!
    
    var separatorView: UIView?
    
    var model        : LTNewsModel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newsLabel.text = ""
        lawNameLabel.text = ""
    }
    
    func fillWithModel(model: LTNewsModel) {
        self.model = model
        
        newsLabel.text = model.status
        lawNameLabel.text = model.billName
        
        newsLabel.fit()
        lawNameLabel.fit()
        
        addSeparator()
    }
    
    private func addSeparator() {
        if let separatorView = self.separatorView as UIView! {
            separatorView.removeFromSuperview()
        }
        
        separatorView = UIView(frame: CGRectMake(0, CGRectGetHeight(contentView.frame) - 1.2, CGRectGetWidth(contentView.frame), 0.8))
        separatorView!.backgroundColor = UIColor(red: 233.0/255.0, green: 235.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        
        contentView.addSubview(separatorView!)
    }
}
