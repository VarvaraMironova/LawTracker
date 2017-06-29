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
    
    func showLoadingViewWithMessage(_ message: String) {
       showLoadingViewInViewWithMessage(self, message: message)
    }
    
    func showLoadingViewInView(_ view: UIView) {
        DispatchQueue.main.async {[unowned self] in
            if !self.loadingViewShown {
                self.loadingView = OTMLoadingView.loadingView(view)
                self.loadingViewShown = true
            }
        }
    }
    
    func showLoadingViewInViewWithMessage(_ view: UIView, message: String) {
        DispatchQueue.main.async {[unowned self] in
            if !self.loadingViewShown {
                self.loadingView = OTMLoadingView.loadingView(view, message: message)
                self.loadingViewShown = true
            } else {
                self.loadingView.changeMessage(message)
            }
        }
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async {[unowned self] in
            if self.loadingViewShown {
                self.loadingView.hide()
                self.loadingView = nil
                self.loadingViewShown = false
            }
        }
    }

}
