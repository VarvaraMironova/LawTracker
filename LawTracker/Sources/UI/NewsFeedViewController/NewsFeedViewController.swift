//
//  NewsFeedViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 4/21/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class NewsFeedViewController: UIViewController {
    @IBOutlet var navigationGesture: LTPanGestureRacognizer!
    
    var currentController     : LTMainContentViewController?
    var destinationController : LTMainContentViewController?
    var animator              : LTSliderAnimator?
    
    internal var rootView : NewsFeedRootView? {
        get {
            if isViewLoaded() && view.isKindOfClass(NewsFeedRootView) {
                return view as? NewsFeedRootView
            } else {
                return nil
            }
        }
    }
    
    //MARK: - Interface Handling
    @IBAction func onGesture(sender: LTPanGestureRacognizer) {
        let direction = sender.direction
        if direction != .Right {
            handlePageSwitchingGesture(sender)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationGesture == gestureRecognizer || navigationGesture == otherGestureRecognizer
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if nil == currentController {
            return false
        }
        
        if nil == currentController!.rootView {
            return false
        }
        
        if nil == rootView {
            return false
        }
        
        navigationGesture.changeDirection()
        if let navigationController = navigationController as UINavigationController! {
            let shouldPop = navigationController.viewControllers.count > 1
            var isNavigationGesture = false
            if let gestureRecognizer = navigationGesture as LTPanGestureRacognizer! {
                let direction = gestureRecognizer.direction
                isNavigationGesture = .Right == direction
            }
            
            if shouldPop && isNavigationGesture {
                return true
            }
            
            if self != navigationController.topViewController {
                return false
            }
            
            let tableView = currentController!.rootView!.contentTableView
            let bounds = tableView.bounds
            let dip = dateInPicker()
            let shouldAnimateToTop = (CGRectGetMinY(bounds) <= 0 && .Down == navigationGesture.direction && dip.dateWithoutTime().compare(NSDate().dateWithoutTime()) == .OrderedAscending)
            let shouldAnimateToBottom = ((CGRectGetMaxY(bounds) >= (tableView.contentSize.height - 1)) && .Up == navigationGesture.direction)
            let shouldBegin = shouldAnimateToTop || shouldAnimateToBottom
            
            return shouldBegin
        }
        
        return false
    }
    
    // MARK: - Private
    private func handlePageSwitchingGesture(recognizer: LTPanGestureRacognizer) {
        if nil == rootView {
            return
        }
        
        let recognizerView = recognizer.view
        let location = recognizer.locationInView(recognizerView)
        let direction = recognizer.direction
        let translation = recognizer.translationInView(recognizerView)
        let state = recognizer.state
        
        if .Changed == state {
            let dx = recognizer.startLocation.x - location.x
            let dy = recognizer.startLocation.y - location.y
            
            let distance = sqrt(dx*dx + dy*dy)
            if distance >= 0.0 {
                if let animator = animator as LTSliderAnimator! {
                    let percent = (.Down == direction && location.y < recognizer.startLocation.y) || (.Up == direction && location.y > recognizer.startLocation.y) ? 0.0 : fabs(distance/CGRectGetHeight(recognizerView!.bounds))
                    animator.updateInteractiveTransition(percent)
                } else {
                    animator = LTSliderAnimator()
                    
                    //instantiate LTMainContentViewController with LTChangesModel
                    let nextController = storyboard!.instantiateViewControllerWithIdentifier("LTMainContentViewController") as! LTMainContentViewController
                    setCurrentController(nextController, animated: true, forwardDirection: .Up == direction)
                    
                    if .Down == direction && translation.y > 0 {
                        if dateInPicker().compare(NSDate()) == .OrderedAscending {
                            self.downloadContent(false)
                        }
                    } else if translation.y < 0 {
                        self.downloadContent(true)
                    }
                }
            }
        } else if .Ended == state {
            let velocity = recognizer.velocityInView(recognizerView)
            if (velocity.y > 0 && .Down == direction) || (velocity.y < 0 && .Up == direction) {
                scrollToTop()
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
            destinationController = controller
            transitionFromViewController(currentController, toViewController: controller, animated: animated, forward: forwardDirection)
        }
    }
    
    func transitionFromViewController(fromViewController: LTMainContentViewController?, toViewController: LTMainContentViewController, animated: Bool, forward: Bool) {
        if false == isViewLoaded() {
            return
        }
        
        let containerView = rootView!.contentView
        
        toViewController.view.translatesAutoresizingMaskIntoConstraints = true
        toViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addChildViewControllerInView(toViewController, view:containerView)
        
        if nil == fromViewController {
            commitFeedController(toViewController)
            
            return
        }
        
        let context = LTTransitionContext(source: fromViewController, destination: toViewController, containerView: containerView, animated: animated, forward: forward)
        context.animator = animator
        
        let interactiveFeedScrollController = false == context.isInteractive() ? LTSliderAnimator() : animator
        if let interactiveFeedScrollController = interactiveFeedScrollController as LTSliderAnimator! {
            interactiveFeedScrollController.operation = forward ? .Pop : .Push
            interactiveFeedScrollController.duration = 0.5
            context.completionBlock = {[unowned self] (complete) in
                if true == complete {
                    self.commitFeedController(toViewController)
                } else {
                    toViewController.view.removeFromSuperview()
                    fromViewController!.view.frame = containerView.bounds
                    self.currentController = fromViewController
                    self.destinationController = nil
                }
                
                interactiveFeedScrollController.animationEnded(complete)
                containerView.userInteractionEnabled = true
            }
            
            containerView.userInteractionEnabled = false
            
            if context.isInteractive() {
                if let _ = animator as LTSliderAnimator! {
                    context.animator!.startInteractiveTransition(context)
                }
            } else {
                interactiveFeedScrollController.animateTransition(context)
            }
        }
    }
    
    func commitFeedController(feedController: LTMainContentViewController) {
        //remove rootView of previous currentController from superview
        if currentController != feedController {
            if nil != currentController {
                removeChildController(currentController!)
            }
            
            currentController = feedController
            destinationController = nil
            feedController.didMoveToParentViewController(self)
        }
    }
    
    func scrollToTop() {
        
    }
    
    func downloadContent(forPreviousDay: Bool) {
        
    }
    
    func dateInPicker() -> NSDate {
        return NSDate()
    }
}
