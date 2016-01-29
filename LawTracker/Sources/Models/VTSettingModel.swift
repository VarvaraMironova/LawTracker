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
        static let Initiators  = "Initiators"
        static let Committees  = "Committees"
        static let Laws        = "Laws"
        static let Filters     = "Filters"
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
    
    var initiators : [String] {
        set {
            if var filters = filters as [String:[String]]! {
                filters[Keys.Initiators] = newValue
            }
        }
        
        get {
            if var filters = filters as [String:[String]]! {
                if let array = filters[Keys.Initiators] as [String]! {
                    return array
                }
            }
            
            return []
        }
    }
    
    var laws : [String] {
        set {
            if var filters = filters as [String:[String]]! {
                filters[Keys.Laws] = newValue
            }
        }
        
        get {
            if var filters = filters as [String:[String]]! {
                if let array = filters[Keys.Laws] as [String]! {
                    return array
                }
            }
            
            return []
        }
    }
    
    var committees : [String] {
        set {
            if var filters = filters as [String:[String]]! {
                filters[Keys.Committees] = newValue
            }
        }
        
        get {
            if var filters = filters as [String:[String]]! {
                if let array = filters[Keys.Committees] as [String]! {
                    return array
                }
            }
            
            return []
        }
    }
    
    var filters : [String:[String]]? {
        set {
            defaults.setObject(newValue, forKey: Keys.Filters)
        }
        
        get {
            return defaults.objectForKey(Keys.Filters) as? [String:[String]]
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
    
    func synchronized(lock: AnyObject, closure:() -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func setup() {
        firstLaunch = true
        filters = [Keys.Initiators:[], Keys.Committees:[], Keys.Laws:[]]
    }
}
