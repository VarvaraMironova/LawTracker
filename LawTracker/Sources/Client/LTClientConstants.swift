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
        static let parseJSONError       = "Неможливо прочитати дані "
        static let noCurrentConvocation = "Не вдалося завантажити інформацію про скликання Верховної Ради "
        static let nsURLError           = "Неможливо згенерувати URL зі строки "
        static let nsRequestError       = "Неможливо згенерувати запит із URL "
        static let emptyDataError       = "Дані з сервера не отримано "
    }
    
    struct kLTConstants {
        static let startDate = "Sat, 01 Jan 2000 00:00:00 GMT"
    }
    
}
