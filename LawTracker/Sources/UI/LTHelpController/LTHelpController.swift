//
//  LTHelpController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 3/3/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

private let kPortrait1 = "screenshot1_portrait"
private let kPortrait2 = "screenshot2_portrait"
private let kPortrait3 = "screenshot3_portrait"
private let kPortrait4 = "screenshot4_portrait"
private let kPortrait5 = "screenshot5_portrait"
private let kPortrait6 = "screenshot6_portrait"
private let kPortrait7 = "screenshot7_portrait"
private let kPortrait8 = "screenshot8_portrait"
private let kPortrait9 = "screenshot9_portrait"
private let kPortrait10 = "screenshot10_portrait"
private let kLandscape1 = "screenshot1_landscape"
private let kLandscape2 = "screenshot2_landscape"
private let kLandscape3 = "screenshot3_landscape"
private let kLandscape4 = "screenshot4_landscape"
private let kLandscape5 = "screenshot5_landscape"
private let kLandscape6 = "screenshot6_landscape"
private let kLandscape7 = "screenshot7_landscape"
private let kLandscape8 = "screenshot8_landscape"
private let kLandscape9 = "screenshot9_landscape"
private let kLandscape10 = "screenshot10_landscape"

class LTHelpController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageViewController : UIPageViewController!
    var pendingIndex       : Int! = 1
    
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
            return [[kPortrait1, kLandscape1], [kPortrait2, kLandscape2], [kPortrait3, kLandscape3], [kPortrait4, kLandscape4], [kPortrait5, kLandscape5], [kPortrait6, kLandscape6], [kPortrait7, kLandscape7], [kPortrait8, kLandscape8], [kPortrait9, kLandscape9], [kPortrait10, kLandscape10]]
        }
    }
    
    var pageIsAnimating : Bool = false
    
    lazy var itemViewControllers: [LTHelpContentController] = {
        var controllers = [LTHelpContentController]()
        for index in 1...10 {
            let contentController = LTHelpContentController(nibName: "LTHelpContentController", bundle: nil)
            contentController.pageIndex = index
            contentController.model = self.helpModel[index - 1]
            
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - Interface Handling
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
        var index: Int = (viewController as! LTHelpContentController).pageIndex - 1
        
        if pageIsAnimating || NSNotFound == index {
            return nil
        }
        
        if index == itemViewControllers.count - 1 {
            return itemViewControllers.first
        }
        
        let destinationController = itemViewControllers[++index]
        
        return destinationController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index: Int = (viewController as! LTHelpContentController).pageIndex - 1
        
        if pageIsAnimating || NSNotFound == index {
            return nil
        }
        
        if index == 0 {
            return itemViewControllers.last
        }
        
        let destinationController = itemViewControllers[--index]
        
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
