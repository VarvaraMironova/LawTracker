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
    
    func addChildViewController(childController: UIViewController, view: UIView) {
        childController.view.frame = view.bounds
        view.addSubview(childController.view)
        self.addChildViewController(childController)
        childController.didMoveToParentViewController(self)
    }
}