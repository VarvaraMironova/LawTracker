//
//  OTMLoadingView.swift
//  OnTheMap
//
//  Created by Varvara Mironova on 9/30/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class OTMLoadingView: UIView {
    @IBOutlet var spinner     : UIActivityIndicatorView!
    @IBOutlet var loadingLabel: UILabel!

    weak var rootView: UIView!
    
    class func loadingView(_ rootView: UIView) -> OTMLoadingView {
        let loadingView = Bundle.main.loadNibNamed("OTMLoadingView", owner: self, options: nil)?.first as! OTMLoadingView

        loadingView.show(rootView)
        
        return loadingView
    }
    
    class func loadingView(_ rootView: UIView, message: String) -> OTMLoadingView {
        let loadingView = Bundle.main.loadNibNamed("OTMLoadingView", owner: self, options: nil)?.first as! OTMLoadingView
        
        loadingView.showWithMessage(rootView, message: message)
        
        return loadingView
    }
    
    fileprivate func show(_ rootView: UIView) {
        var frame = rootView.frame as CGRect
        frame.origin = CGPoint.zero;
        self.frame = frame;
        
        rootView.addSubview(self)
        
        self.rootView = rootView
        
        spinner.startAnimating()
        animate(1.0)
    }
    
    fileprivate func animate(_ alpha: CGFloat) {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = alpha
            }, completion: {(finished: Bool) -> Void in
                
        })
    }
    
    fileprivate func showWithMessage(_ rootView: UIView, message: String) {
        show(rootView)
        
        loadingLabel.isHidden = false
        loadingLabel.text = message
    }
    
    func changeMessage(_ message: String) {
        loadingLabel.text = message
    }
    
    func hide() {
        if isDescendant(of: rootView) {
            animate(0.0)
            spinner.stopAnimating()
            removeFromSuperview()
        }
    }
}
