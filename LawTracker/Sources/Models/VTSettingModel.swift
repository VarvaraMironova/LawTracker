//
//  VTSettingModel.swift
//  VirtualTourist
//
//  Created by Varvara Mironova on 11/25/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import MapKit

class VTSettingModel: NSObject {
    var defaults    : UserDefaults
    
    struct Keys {
        static let FirstLaunch = "firstLaunch"
        static let Date        = "lastDownloadDate"
    }
    
    var firstLaunch : Bool {
        get {
            return defaults.bool(forKey: Keys.FirstLaunch)
        }
        
        set {
            defaults.set(newValue, forKey: Keys.FirstLaunch)
        }
    }
    
    var lastDownloadDate : Date? {
        set {
            defaults.set(newValue!.dateWithoutTime(), forKey: Keys.Date)
        }
        
        get {
            if let date = defaults.object(forKey: Keys.Date) as? Date {
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
        self.defaults = UserDefaults.standard
        
        super.init()
    }
    
    override func setNilValueForKey(_ key: String) {
        synchronized(self, closure: {
            self.defaults.removeObject(forKey: key)
            self.defaults.synchronize()
        })
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        synchronized(self, closure: {
            self.defaults.setValue(value, forKey: key)
            self.defaults.synchronize()
        })
    }
    
    func setup() {
        firstLaunch = true
    }
}
