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
            if isViewLoaded && view.isKind(of: LTHelpContentView.self) {
                return view as? LTHelpContentView
            } else {
                return nil
            }
        }
    }
    
    var model : [String]!
    
    var pageIndex : Int!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rootView!.fill(model)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: {[weak rootView = rootView] (UIViewControllerTransitionCoordinatorContext) -> Void in
            if let rootView = rootView as LTHelpContentView! {
                rootView.fill(self.model)
            }}, completion: {(UIViewControllerTransitionCoordinatorContext) -> Void in })
    }

}
