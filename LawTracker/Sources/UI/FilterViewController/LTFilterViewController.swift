//
//  LTFilterViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

enum LTFilterType : Int {
    case byCommettees = 0, byInitializers = 1, byLaws = 2
    
    static let filterTypes = [byCommettees, byInitializers, byLaws]
}

class LTFilterViewController: UIViewController {
    var type         : LTFilterType = .byCommettees
    weak var delegate: LTMainContentViewControllerViewController!
    
    
    var rootView: LTFilterRootView! {
        get {
            if isViewLoaded() && self.view.isKindOfClass(LTFilterRootView) {
                return self.view as? LTFilterRootView
            } else {
                return nil
            }
        }
    }
    
    @IBAction func onRemoveCellButton(sender: AnyObject) {
        
    }
    
    @IBAction func onOkButton(sender: AnyObject) {
        
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        
    }
    
}
