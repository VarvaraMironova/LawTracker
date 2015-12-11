//
//  LTUtility.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

class LTUtility {
    class func classToString(obj: Any) -> String {
        return _stdlib_getDemangledTypeName(obj).componentsSeparatedByString(".").last!
    }
}
