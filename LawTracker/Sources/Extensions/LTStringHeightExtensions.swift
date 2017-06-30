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
    func getHeight(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func date() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = dateFormatter.date(from: self) as Date! {
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
            let attributes = [NSLinkAttributeName: self, NSFontAttributeName: font] as [String : Any]
            
            return NSMutableAttributedString(string:self, attributes:attributes)
        }
        
        return nil
    }
}
