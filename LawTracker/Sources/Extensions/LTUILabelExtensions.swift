//
//  LTUILabelExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

extension UILabel {
    
    func fit() {
        numberOfLines = 0
        var rect = frame
        let size = sizeThatFits(CGSizeMake(CGRectGetWidth(frame), 0))
        rect.size.height = size.height
        frame = rect
    }
}
