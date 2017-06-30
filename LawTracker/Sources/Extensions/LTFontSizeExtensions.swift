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
        let widthProportionalSize = pointSize * UIScreen.main.bounds.width / 414.0
        let fontSize = widthProportionalSize < pointSize ? widthProportionalSize : pointSize
        
        return UIFont(name: fontName, size: fontSize)!
    }
    
}
