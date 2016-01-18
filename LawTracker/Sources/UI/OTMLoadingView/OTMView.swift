//
//  OTMView.swift
//  OnTheMap
//
//  Created by Varvara Mironova on 10/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class OTMView: UIView {
    var loadingViewShown : Bool = false
    var loadingView      : OTMLoadingView!
    
    func showLoadingView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.showLoadingViewInView(self)
        }
    }
    
    func showLoadingViewWithMessage(message: String) {
//        dispatch_async(dispatch_get_main_queue()) {
            self.showLoadingViewInViewWithMessage(self, message: message)
//        }
    }
    
    func showLoadingViewInView(view: UIView) {
        if !loadingViewShown {
            loadingView = OTMLoadingView.loadingView(view)
            loadingViewShown = true
        }
    }
    
    func showLoadingViewInViewWithMessage(view: UIView, message: String) {
        if !loadingViewShown {
            loadingView = OTMLoadingView.loadingView(view, message: message)
            loadingViewShown = true
        } else {
            loadingView.changeMessage(message)
        }
    }
    
    func hideLoadingView() {
        if loadingViewShown {
            loadingView.hide()
            loadingView = nil
            loadingViewShown = false
        }
    }

}
