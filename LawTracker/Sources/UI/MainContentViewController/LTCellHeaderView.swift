//
//  LTCellHeaderView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTCellHeaderView: UIView {
    @IBOutlet var titleLabel: UILabel!
    
    class func headerView() -> LTCellHeaderView {
        let headerView = Bundle.main.loadNibNamed("LTCellHeaderView", owner: self, options: nil)?.first as! LTCellHeaderView
        
        return headerView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = ""
    }

    func fillWithString(_ title: String) {
        titleLabel.text = title
        titleLabel.fit()
    }

}
