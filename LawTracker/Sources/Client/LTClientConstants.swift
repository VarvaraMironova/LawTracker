//
//  LTClientConstants.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

extension LTClient {
    struct kVTParameters {
        static let baseURL = "http://www.chesno.org"
        static let extras  = "api"
        static let radaID  = "1"
        static let format  = "json"
    }
    
    struct kLTAPINames {
        static let persons     = "persons"
        static let council     = "council"
        static let legislation = "legislation"
    }
    
    struct kLTMethodNames {
        static let convocation      = "convocation"
        static let bill             = "bill"
        static let committees       = "committees"
        static let deputies         = "deputies"
        static let initiators       = "initiators"
        static let initiatorTypes   = "initiator-types"
        static let billStatuses     = "bill-statuses"
    }
    
    struct kVTKeys {
        static let laws       = "laws"
        static let initiators = "initiators"
        static let committees = "committees"
        static let changes    = "changes"
    }
    
    struct KLTMessages {
        static let parseJSONError       = "Cannot parse JSON"
        static let noCurrentConvocation = "Try reload data"
        static let nsURLError           = "Cannot get url from string"
        static let nsRequestError       = "Cannot create request with url"
    }
    
}
