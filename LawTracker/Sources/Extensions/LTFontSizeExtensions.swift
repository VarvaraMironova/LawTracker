//
//  LTFontSizeExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

extension UIFont {
    
    func screenProportionalFont() -> UIFont {
        let fontSize = pointSize * CGRectGetWidth(UIScreen.mainScreen().bounds) / 414.0
        
        return UIFont(name: fontName, size: fontSize)!
    }
    
}
