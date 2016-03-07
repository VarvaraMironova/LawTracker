//
//  LTChildViewControllerExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/9/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func addChildViewControllerInView(childController: UIViewController, view: UIView) {
        childController.view.frame = view.bounds
        view.addSubview(childController.view)
        addChildViewController(childController)
        childController.didMoveToParentViewController(self)
    }
    
    func removeChildController(childController: UIViewController) {
        dispatch_async(dispatch_get_main_queue()) {
            childController.willMoveToParentViewController(nil)
            childController.view.removeFromSuperview()
            childController.removeFromParentViewController()
        }
    }
    
    func displayError(error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            let alertViewController: UIAlertController = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction(title: "Продовжити", style: .Default, handler: nil))
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
    }
}