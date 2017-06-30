//
//  LTNSDateExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

extension Date {
    
    func string(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = format
        
        if let result = dateFormatter.string(from: self) as String! {
            return result
        }
        
        return ""
    }
    
    func longString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "uk-Cyrl")
        
        if let result = dateFormatter.string(from: self) as String! {
            return result
        }
        
        return ""
    }
    
    func previousDay() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = components.day! - 1
        return calendar.date(from: components)!
    }
    
    func nextDay() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = components.day! + 1
        return calendar.date(from: components)!
    }
    
    func dateWithoutTime() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: self)
        
        return calendar.date(from: components)!
    }

}
