//
//  LTSectionModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation

struct LTSectionModel {
    var title: String!
    var news : [LTNewsModel]!
    
    init(title: String!, news: [LTNewsModel]!) {
        self.title = title
        self.news = news
    }
}