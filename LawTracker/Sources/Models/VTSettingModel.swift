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
            filters[Keys.Initiators] = newValue
        }
        
        get {
            if nil != filters[Keys.Initiators] {
                if let array = filters[Keys.Initiators] as [String]! {
                    return array
                }
            }
            
            return []
        }
    }
    
    var laws : [String] {
        set {
            filters[Keys.Laws] = newValue
        }
        
        get {
            if nil != filters[Keys.Laws] {
                if let array = filters[Keys.Laws] as [String]! {
                    return array
                }
            }
            
            return []
        }
    }
    
    var committees : [String] {
        set {
            filters[Keys.Committees] = newValue
        }
        
        get {
            if nil != filters[Keys.Committees] {
                if let array = filters[Keys.Committees] as [String]! {
                    return array
                }
            }
            
            return []
        }
    }
    
    var filters : [String:[String]] {
        set {
            defaults.setObject(newValue, forKey: Keys.Filters)
        }
        
        get {
            return defaults.objectForKey(Keys.Filters) as! [String:[String]]
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
    
    func createFilters() {
        filters = [Keys.Initiators:[], Keys.Committees:[], Keys.Laws:[]]
    }
}
