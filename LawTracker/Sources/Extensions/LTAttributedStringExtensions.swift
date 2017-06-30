//
//  LTAttributedStringExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/14/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: NSAttributedString {
    func joinWithSeparator(_ separator: NSAttributedString) -> NSAttributedString {
        var isFirst = true
        return self.reduce(NSMutableAttributedString()) {
            (result, item) in
            if isFirst {
                isFirst = false
            } else {
                result.append(separator)
            }
            
            result.append(item)
            
            return result
        }
    }
}

