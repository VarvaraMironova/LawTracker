//
//  LTNSDateExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

extension NSDate {
    
    func string() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar.currentCalendar()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let result = dateFormatter.stringFromDate(self) as String! {
            return result
        }
        
        return ""
    }
    
    func shirtString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar.currentCalendar()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let result = dateFormatter.stringFromDate(self) as String! {
            return result
        }
        
        return ""
    }
}
