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
        showLoadingViewInView(self)
    }
    
    func showLoadingViewWithMessage(message: String) {
       showLoadingViewInViewWithMessage(self, message: message)
    }
    
    func showLoadingViewInView(view: UIView) {
        dispatch_async(dispatch_get_main_queue()) {
            if !self.loadingViewShown {
                self.loadingView = OTMLoadingView.loadingView(view)
                self.loadingViewShown = true
            }
        }
    }
    
    func showLoadingViewInViewWithMessage(view: UIView, message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            if !self.loadingViewShown {
                self.loadingView = OTMLoadingView.loadingView(view, message: message)
                self.loadingViewShown = true
            } else {
                self.loadingView.changeMessage(message)
            }
        }
    }
    
    func hideLoadingView() {
        dispatch_async(dispatch_get_main_queue()) {
            if self.loadingViewShown {
                self.loadingView.hide()
                self.loadingView = nil
                self.loadingViewShown = false
            }
        }
    }

}
