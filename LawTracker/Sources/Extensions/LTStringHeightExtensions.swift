//
//  LTStringHeightExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func getHeight(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func date() -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = dateFormatter.dateFromString(self) as NSDate! {
            return date
        }
        
        return nil
    }
    
    func attributedTitle() -> NSAttributedString? {
        if let font = UIFont(name: "Arial-BoldMT", size: 14.0) as UIFont! {
            let attributes = [NSFontAttributeName: font]
            
            return NSMutableAttributedString(string:self, attributes:attributes)
        }
        
        return nil
    }
    
    func attributedText() -> NSAttributedString? {
        if let font = UIFont(name: "Arial", size: 12.0) as UIFont! {
            let attributes = [NSFontAttributeName: font]
            
            return NSMutableAttributedString(string:self, attributes:attributes)
        }
        
        return nil
    }
    
    func attributedLink() -> NSAttributedString? {
        if let font = UIFont(name: "Arial", size: 12.0) as UIFont! {
            let attributes = [NSLinkAttributeName: self, NSFontAttributeName: font]
            
            return NSMutableAttributedString(string:self, attributes:attributes)
        }
        
        return nil
    }
}