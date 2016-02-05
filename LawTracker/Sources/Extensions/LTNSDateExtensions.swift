//
//  LTNSDateExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

extension NSDate {
    
    func string(format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar.currentCalendar()
        dateFormatter.dateFormat = format
        
        if let result = dateFormatter.stringFromDate(self) as String! {
            return result
        }
        
        return ""
    }
    
    func longString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar.currentCalendar()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "uk-Cyrl")
        
        if let result = dateFormatter.stringFromDate(self) as String! {
            return result
        }
        
        return ""
    }
    
    func previousDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        components.day -= 1
        
        return calendar.dateFromComponents(components)!
    }
    
    func nextDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        components.day += 1
        
        return calendar.dateFromComponents(components)!
    }
    
    func dateWithoutTime() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        return calendar.dateFromComponents(components)!
    }

}
