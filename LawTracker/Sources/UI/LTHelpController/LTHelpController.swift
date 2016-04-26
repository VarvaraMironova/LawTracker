//
//  LTHelpController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 3/3/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTHelpController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageViewController : UIPageViewController!
    var pendingIndex       : Int! = 1
    
    var upSwipeGestureRecognizer: UISwipeGestureRecognizer!
    var downSwipeGestureRecognizer: UISwipeGestureRecognizer!
    
    var rootView: LTHelpView? {
        get {
            if isViewLoaded() && view.isKindOfClass(LTHelpView) {
                return view as? LTHelpView
            } else {
                return nil
            }
        }
    }
    
    var helpModel: [[String]]! {
        get {
            return [[kLTManual.portrait1, kLTManual.landscape1], [kLTManual.portrait2, kLTManual.landscape2], [kLTManual.portrait3, kLTManual.landscape3], [kLTManual.portrait4, kLTManual.landscape4], [kLTManual.portrait5, kLTManual.landscape5], [kLTManual.portrait6, kLTManual.landscape6], [kLTManual.portrait7, kLTManual.landscape7], [kLTManual.portrait8, kLTManual.landscape8], [kLTManual.portrait9, kLTManual.landscape9], [kLTManual.portrait10, kLTManual.landscape10]]
        }
    }
    
    var helpModel4s: [[String]]! {
        get {
            return [[kLTiPhones4Manual.portrait1, kLTiPhones4Manual.landscape1], [kLTiPhones4Manual.portrait2, kLTiPhones4Manual.landscape2], [kLTiPhones4Manual.portrait3, kLTiPhones4Manual.landscape3], [kLTiPhones4Manual.portrait4, kLTiPhones4Manual.landscape4], [kLTiPhones4Manual.portrait5, kLTiPhones4Manual.landscape5], [kLTiPhones4Manual.portrait6, kLTiPhones4Manual.landscape6], [kLTiPhones4Manual.portrait7, kLTiPhones4Manual.landscape7], [kLTiPhones4Manual.portrait8, kLTiPhones4Manual.landscape8], [kLTiPhones4Manual.portrait9, kLTiPhones4Manual.landscape9], [kLTiPhones4Manual.portrait10, kLTiPhones4Manual.landscape10]]
        }
    }
    
    var helpModel5: [[String]]! {
        get {
            return [[kLTiPhones5Manual.portrait1, kLTiPhones5Manual.landscape1], [kLTiPhones5Manual.portrait2, kLTiPhones5Manual.landscape2], [kLTiPhones5Manual.portrait3, kLTiPhones5Manual.landscape3], [kLTiPhones5Manual.portrait4, kLTiPhones5Manual.landscape4], [kLTiPhones5Manual.portrait5, kLTiPhones5Manual.landscape5], [kLTiPhones5Manual.portrait6, kLTiPhones5Manual.landscape6], [kLTiPhones5Manual.portrait7, kLTiPhones5Manual.landscape7], [kLTiPhones5Manual.portrait8, kLTiPhones5Manual.landscape8], [kLTiPhones5Manual.portrait9, kLTiPhones5Manual.landscape9], [kLTiPhones5Manual.portrait10, kLTiPhones5Manual.landscape10]]
        }
    }
    
    var helpModelPro: [[String]]! {
        get {
            return [[kLTiPadsProManual.portrait1, kLTiPadsProManual.landscape1], [kLTiPadsProManual.portrait2, kLTiPadsProManual.landscape2], [kLTiPadsProManual.portrait3, kLTiPadsProManual.landscape3], [kLTiPadsProManual.portrait4, kLTiPadsProManual.landscape4], [kLTiPadsProManual.portrait5, kLTiPadsProManual.landscape5], [kLTiPadsProManual.portrait6, kLTiPadsProManual.landscape6], [kLTiPadsProManual.portrait7, kLTiPadsProManual.landscape7], [kLTiPadsProManual.portrait8, kLTiPadsProManual.landscape8], [kLTiPadsProManual.portrait9, kLTiPadsProManual.landscape9], [kLTiPadsProManual.portrait10, kLTiPadsProManual.landscape10]]
        }
    }
    
    var pageIsAnimating : Bool = false
    
    lazy var itemViewControllers: [LTHelpContentController] = {
        var controllers = [LTHelpContentController]()
        
        for index in 1...10 {
            let contentController = LTHelpContentController(nibName: "LTHelpContentController", bundle: nil)
            contentController.pageIndex = index
            
            var models = self.helpModel
            let device = UIDevice.currentDevice()
            
            if device.isiPhone4() {
                models = self.helpModel4s
            } else if device.isiPhone5() {
                models = self.helpModel5
            } else if device.isiPadPro() {
                models = self.helpModelPro
            }
            
            contentController.model = models[index - 1]
            
            controllers.append(contentController)
        }
        
        return controllers
    }()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        let pageViewController = storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        if let firstItem = itemViewControllers.first as LTHelpContentController! {
            pageViewController.setViewControllers([firstItem], direction: .Forward, animated: true) {[weak pageViewController = pageViewController] (finished) -> Void in
                if finished {
                    if let pageViewController = pageViewController as UIPageViewController! {
                        dispatch_async(dispatch_get_main_queue()) {
                            pageViewController.setViewControllers([firstItem], direction: .Forward, animated: false, completion: nil)
                        }
                    }
                }
            }
            
            if let rootView = rootView as LTHelpView! {
                addChildViewControllerInView(pageViewController, view: rootView.contentView)
                self.pageViewController = pageViewController
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //add swipe gecture recognizers
        let upGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(LTHelpController.onSwipe(_:)))
        upGestureRecognizer.direction = .Up
        
        pageViewController.view.addGestureRecognizer(upGestureRecognizer)
        upSwipeGestureRecognizer = upGestureRecognizer
        
        let downGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(LTHelpController.onSwipe(_:)))
        downGestureRecognizer.direction = .Down
        
        pageViewController.view.addGestureRecognizer(downGestureRecognizer)
        downSwipeGestureRecognizer = downGestureRecognizer
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //remove swipe gecture recognizers
        upSwipeGestureRecognizer.removeTarget(self, action: #selector(LTHelpController.onSwipe(_:)))
        downSwipeGestureRecognizer.removeTarget(self, action: #selector(LTHelpController.onSwipe(_:)))
        pageViewController.view.removeGestureRecognizer(upSwipeGestureRecognizer)
        pageViewController.view.removeGestureRecognizer(downSwipeGestureRecognizer)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - Interface Handling
    @IBAction func onSwipe(sender: UISwipeGestureRecognizer) {
        if .Up == sender.direction || .Down == sender.direction {
            onCloseButton(sender)
        }
    }
    
    @IBAction func onCloseButton(sender: AnyObject) {
        if let navigationController = navigationController as UINavigationController! {
            let newsFeedController = self.storyboard!.instantiateViewControllerWithIdentifier("LTNewsFeedViewController") as! LTNewsFeedViewController
            navigationController.viewControllers = [newsFeedController]
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //MARK: - UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index: Int = (viewController as! LTHelpContentController).pageIndex - 1
        
        if pageIsAnimating || NSNotFound == index {
            return nil
        }
        
        if index == itemViewControllers.count - 1 {
            return itemViewControllers.first
        }
        
        let destinationController = itemViewControllers[index+1]
        
        return destinationController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index: Int = (viewController as! LTHelpContentController).pageIndex - 1
        
        if pageIsAnimating || NSNotFound == index {
            return nil
        }
        
        if index == 0 {
            return itemViewControllers.last
        }
        
        let destinationController = itemViewControllers[index-1]
        
        return destinationController
    }
    
    //MARK: - UIPageViewControllerDelegate
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pageIsAnimating = true
        if let controller = pendingViewControllers.first as? LTHelpContentController! {
            pendingIndex = controller.pageIndex
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            pageIsAnimating = false
            if let rootView = rootView as LTHelpView! {
                rootView.pageControl.currentPage = pendingIndex - 1
            }
        }
    }
}
