//
//  LTClientConstants.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

extension LTClient {
    struct kVTParameters {
        static let baseURL        = "https://api.flickr.com/services/rest/"
        static let methodName     = "flickr.photos.search"
        static let APIKey         = "997631065d8b180112f22052ec0003be"
        static let extras         = "url_m"
        static let dataFormat     = "json"
        static let safeSearch     = "1"
        static let noJSONCallback = "1"
    }
    
    struct kVTKeys {
        static let laws         = "laws"
        static let initialisers = "initialisers"
        static let committees   = "committees"
        static let changes      = "changes"
    }
    
}
