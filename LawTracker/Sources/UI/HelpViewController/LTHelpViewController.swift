//
//  LTHelpViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/15/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTHelpViewController: UIViewController {
    weak var delegate: LTMainContentViewControllerViewController!
    
    var rootView: LTHelpRootView! {
        get {
            if isViewLoaded() && view.isKindOfClass(LTHelpRootView) {
                return view as! LTHelpRootView
            } else {
                return nil
            }
        }
    }

    @IBAction func onCloseButton(sender: UIButton) {
        delegate.onDismissFilterViewButton(sender)
    }

}
