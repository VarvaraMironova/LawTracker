//
//  LTAttributedStringExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/14/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

extension SequenceType where Generator.Element: NSAttributedString {
    func joinWithSeparator(separator: NSAttributedString) -> NSAttributedString {
        var isFirst = true
        return self.reduce(NSMutableAttributedString()) {
            (result, item) in
            if isFirst {
                isFirst = false
            } else {
                result.appendAttributedString(separator)
            }
            
            result.appendAttributedString(item)
            
            return result
        }
    }
}

