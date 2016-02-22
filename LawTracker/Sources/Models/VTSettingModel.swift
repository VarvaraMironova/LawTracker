//
//  VTSettingModel.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/25/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import MapKit

class VTSettingModel: NSObject {
    var defaults    : NSUserDefaults
    
    struct Keys {
        static let FirstLaunch = "firstLaunch"
        static let Date        = "lastDownloadDate"
    }
    
    var firstLaunch : Bool {
        get {
            return defaults.boolForKey(Keys.FirstLaunch)
        }
        
        set {
            defaults.setBool(newValue, forKey: Keys.FirstLaunch)
        }
    }
    
    var lastDownloadDate : NSDate? {
        set {
            defaults.setObject(newValue!.dateWithoutTime(), forKey: Keys.Date)
        }
        
        get {
            if let date = defaults.objectForKey(Keys.Date) as? NSDate {
                return date.dateWithoutTime()
            } else {
                return nil
            }
        }
    }
    
    deinit {
        self.defaults.synchronize()
    }
    
    override init() {
        self.defaults = NSUserDefaults.standardUserDefaults()
        
        super.init()
    }
    
    override func setNilValueForKey(key: String) {
        synchronized(self, closure: {
            self.defaults.removeObjectForKey(key)
            self.defaults.synchronize()
        })
    }
    
    override func setValue(value: AnyObject?, forKey key: String) {
        synchronized(self, closure: {
            self.defaults.setValue(value, forKey: key)
            self.defaults.synchronize()
        })
    }
    
    func setup() {
        firstLaunch = true
    }
}
