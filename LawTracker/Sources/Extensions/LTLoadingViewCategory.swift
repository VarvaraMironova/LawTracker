//
//  LTLoadingViewCategory.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/18/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

private var LTLoadingViewShownPropertyKey: UInt8 = 0
private var LTLoadingViewPropertyKey: UInt8 = 0

extension UIView {
    var loadingViewShown : Bool? {
        get {
            return objc_getAssociatedObject(self, &LTLoadingViewShownPropertyKey) as? Bool
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &LTLoadingViewShownPropertyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var loadingView : OTMLoadingView? {
        get {
            return objc_getAssociatedObject(self, &LTLoadingViewPropertyKey) as? OTMLoadingView
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &LTLoadingViewPropertyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func showLoadingView() {
        showLoadingViewInView(self)
    }
    
    func showLoadingViewWithMessage(message: String) {
        showLoadingViewInViewWithMessage(self, message: message)
    }
    
    func showLoadingViewInView(view: UIView) {
        dispatch_async(dispatch_get_main_queue()) {
            if false == self.loadingViewShown {
                self.loadingView = OTMLoadingView.loadingView(view)
                self.loadingViewShown = true
            }
        }
    }
    
    func showLoadingViewInViewWithMessage(view: UIView, message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            if false == self.loadingViewShown {
                self.loadingView = OTMLoadingView.loadingView(view, message: message)
                self.loadingViewShown = true
            } else {
                if let loadingView = self.loadingView as OTMLoadingView! {
                    loadingView.changeMessage(message)
                }
            }
        }
    }
    
    func hideLoadingView() {
        dispatch_async(dispatch_get_main_queue()) {
            if true == self.loadingViewShown {
                if let loadingView = self.loadingView as OTMLoadingView! {
                    loadingView.hide()
                }
                
                self.loadingViewShown = false
            }
        }
    }
}
