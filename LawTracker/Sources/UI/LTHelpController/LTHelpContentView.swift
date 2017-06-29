//
//  LTHelpContentView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 3/3/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTHelpContentView: UIView {

    @IBOutlet var contentImageView: UIImageView!
    
    func fill(_ model: [String]) {
        if .portrait == UIApplication.shared.statusBarOrientation {
            contentImageView.image = UIImage(named: model.first!)
        } else {
            contentImageView.image = UIImage(named: model.last!)
        }
    }
}
