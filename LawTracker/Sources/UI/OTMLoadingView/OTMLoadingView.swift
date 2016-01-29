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
    
    class func loadingView(rootView: UIView) -> OTMLoadingView {
        let loadingView = NSBundle.mainBundle().loadNibNamed("OTMLoadingView", owner: self, options: nil).first as! OTMLoadingView

        loadingView.show(rootView)
        
        return loadingView
    }
    
    class func loadingView(rootView: UIView, message: String) -> OTMLoadingView {
        let loadingView = NSBundle.mainBundle().loadNibNamed("OTMLoadingView", owner: self, options: nil).first as! OTMLoadingView
        
        loadingView.showWithMessage(rootView, message: message)
        
        return loadingView
    }
    
    private func show(rootView: UIView) {
        var frame = rootView.frame as CGRect
        frame.origin = CGPointZero;
        self.frame = frame;
        
        rootView.addSubview(self)
        
        self.rootView = rootView
        
        spinner.startAnimating()
        animate(1.0)
    }
    
    private func animate(alpha: CGFloat) {
        UIView.animateWithDuration(0.4, animations: {
            self.alpha = alpha
            }, completion: {(finished: Bool) -> Void in
                
        })
    }
    
//    - (void)animateWithDuration:(CGFloat)duration
//    withAlpha:(CGFloat)alpha
//    withCompletionHandler:(void (^)(BOOL finished))completionBlock
//    {
//    [UIView animateWithDuration:duration
//    delay:VMDilay
//    options:UIViewAnimationOptionBeginFromCurrentState
//    animations:^{
//    self.alpha = alpha;
//    }
//    completion:completionBlock];
//    }
    
    private func showWithMessage(rootView: UIView, message: String) {
        show(rootView)
        
        loadingLabel.hidden = false
        loadingLabel.text = message
    }
    
    func changeMessage(message: String) {
        loadingLabel.text = message
    }
    
    func hide() {
        if isDescendantOfView(rootView) {
            animate(0.0)
            spinner.stopAnimating()
            removeFromSuperview()
        }
    }
}
