//
//  LTNewsFeedViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTNewsFeedViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var navigationGesture: LTPanGestureRacognizer!
    
    var currentController : LTMainContentViewController!
    var newsFeedModel     : LTChangesModel!
    var animator          : LTSliderAnimator?
    var currentDate       : NSDate!
    
    var rootView     : LTNewsFeedRootView! {
        get {
            if isViewLoaded() && view.isKindOfClass(LTNewsFeedRootView) {
                return view as! LTNewsFeedRootView
            } else {
                return nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Interface Handling
    @IBAction func onGesture(sender: LTPanGestureRacognizer) {
        let direction = sender.direction
        if direction != .Right {
            handlePageSwitchingGesture(sender)
        }
    }
    
    // MARK: - Public
    func setupNews(changesModel: LTChangesModel) {
        
//        NWZArticleContext *context = [model contextForCategoryAtIndex:index];
//        NWZTableViewController *tableViewController = [NWZTableViewController viewControllerWithDefaultNib];
//        
//        tableViewController.context = context;
//        model.currentCategoryIndex = index;
//        
//        [self setCurrentController:tableViewController];
//        [self scrollToTop];
    }
    
    // MARK: - Private
    func handlePageSwitchingGesture(recognizer: LTPanGestureRacognizer) {
        let location = recognizer.locationInView(recognizer.view)
        let direction = recognizer.direction
        let translation = recognizer.translationInView(recognizer.view)
        let state = recognizer.state
        
        if .Changed == state {
            let dx = recognizer.startLocation.x - location.x;
            let dy = recognizer.startLocation.y - location.y;
            
            let distance = sqrt(dx*dx + dy*dy)
            if distance >= 0.0 {
                if let animator = animator as LTSliderAnimator! {
                    let percent = (.Down == direction && location.y < recognizer.startLocation.y) || (.Up == direction && location.y > recognizer.startLocation.y) ? 0.0 : fabs(distance/CGRectGetHeight(view.bounds))
                    animator.updateInteractiveTransition(percent)
                } else {
                    animator = LTSliderAnimator()
                    if .Down == direction && translation.y > 0 {
                        //downloadChanges previous day -> LTChangesModel
                    } else if translation.y < 0 {
                        //downloadChanges for next day -> LTChangesModel
                    }
                    
                    //instantiate LTMainContentViewController with LTChangesModel
                    let currentController = storyboard!.instantiateViewControllerWithIdentifier("LTMainContentViewController") as! LTMainContentViewController
                    setCurrentController(currentController, animated: true, forwardDirection: .Up == direction)
                }
            }
        } else if .Ended == state {
            let velocity = recognizer.velocityInView(recognizer.view)
            if (velocity.y > 0 && .Down == direction) || (velocity.y < 0 && .Up == direction) {
                animator?.finishInteractiveTransition()
            } else {
                animator?.cancelInteractiveTransition()
            }
        } else if .Cancelled == state {
            animator?.cancelInteractiveTransition()
        }
        
        if .Cancelled == state || .Ended == state {
            animator = nil
        }
    }
    
    func setCurrentController(controller: LTMainContentViewController, animated: Bool, forwardDirection: Bool) {
        if currentController != controller {
            transitionFromViewController(currentController, toViewController: controller, animated: animated, forward: forwardDirection)
        }
    }
    
    func transitionFromViewController(fromViewController: LTMainContentViewController?, toViewController: LTMainContentViewController, animated: Bool, forward: Bool) {
        if false == isViewLoaded() {
            return
        }
        
        let containerView = rootView.contentView
        addChildViewController(toViewController, view: containerView)
        let destinationView = toViewController.rootView
        destinationView.translatesAutoresizingMaskIntoConstraints = true
        destinationView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        if let _ = fromViewController as LTMainContentViewController! {
            commitFeedController(toViewController)
            
            return
        }
        
        let context = LTTransitionContext(source: fromViewController, destination: toViewController, containerView: containerView, animated: animated, forward: forward)
        context.animator = animator
        
        let interactiveFeedScrollController = false == context.isInteractive() ? LTSliderAnimator() : animator
        if let interactiveFeedScrollController = interactiveFeedScrollController as LTSliderAnimator! {
            interactiveFeedScrollController.operation = forward ? .Pop : .Push
            interactiveFeedScrollController.duration = 0.75
            context.completionBlock = {complete in
                if true == complete {
                    self.commitFeedController(toViewController)
                } else {
                    toViewController.rootView.removeFromSuperview()
                    if let fromViewController = fromViewController as LTMainContentViewController! {
                         fromViewController.rootView.frame = containerView.bounds
                    }
                }
                
                interactiveFeedScrollController.animationEnded(complete)
                containerView.userInteractionEnabled = true
            }
            
            containerView.userInteractionEnabled = false
            
            if context.isInteractive() {
                context.animator.startInteractiveTransition(context)
            } else {
                interactiveFeedScrollController.animateTransition(context)
            }
        }
    }
    
    func commitFeedController(feedController: LTMainContentViewController) {
        if currentController != feedController {
            removeChildViewController(currentController)
            currentController = feedController
            feedController.didMoveToParentViewController(self)
        }
    }
    
}
