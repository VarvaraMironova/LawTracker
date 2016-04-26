//
//  LTString+DateExtension.swift
//  LawTracker
//
//  Created by Varvara Mironova on 4/12/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

extension String {
    
    func httpDateToNSDate() -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        
        return dateFormatter.dateFromString(self)
    }
}
