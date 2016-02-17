//
//  LTNSObject.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/26/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

enum LTType : Int {
    case byCommittees = 0, byInitiators = 1, byLaws = 2
    
    static let filterTypes = [byCommittees, byInitiators, byLaws]
}

enum LTState : Int {
    case loaded = 0, loading = 1, failed = 2
    
    static let filterTypes = [loaded, loading, failed]
}

extension NSObject {
    
}
