//
//  LTHelpContentController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 3/3/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTHelpContentController: UIViewController {

    var rootView: LTHelpContentView? {
        get {
            if isViewLoaded() && view.isKindOfClass(LTHelpContentView) {
                return view as? LTHelpContentView
            } else {
                return nil
            }
        }
    }
    
    var model : [String]!
    
    var pageIndex : Int!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        rootView!.fill(model)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({[weak rootView = rootView] (UIViewControllerTransitionCoordinatorContext) -> Void in
            if let rootView = rootView as LTHelpContentView! {
                rootView.fill(self.model)
            }}, completion: {(UIViewControllerTransitionCoordinatorContext) -> Void in })
    }

}
