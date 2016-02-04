//
//  LTMainContentRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

let titleOne = "За комітетами"
let titleTwo = "За ініціаторами"
let titleThree = "За законопроектами"

class LTMainContentRootView: OTMView {
    @IBOutlet var contentTableView       : UITableView!
    @IBOutlet var noSubscriptionsLabel   : UILabel!
    @IBOutlet var contentView            : UIView!
    
}
