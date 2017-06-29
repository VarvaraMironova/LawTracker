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
    
    func addChildViewControllerInView(_ childController: UIViewController, view: UIView) {
        childController.view.frame = view.bounds
        view.addSubview(childController.view)
        addChildViewController(childController)
        childController.didMove(toParentViewController: self)
    }
    
    func removeChildController(_ childController: UIViewController) {
        DispatchQueue.main.async {
            childController.willMove(toParentViewController: nil)
            childController.view.removeFromSuperview()
            childController.removeFromParentViewController()
        }
    }
    
    func displayError(_ error: NSError) {
        DispatchQueue.main.async {[unowned self] in
            let alertViewController: UIAlertController = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "Продовжити", style: .default, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
}
