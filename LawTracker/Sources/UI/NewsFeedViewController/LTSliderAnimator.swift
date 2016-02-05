//
//  LTSliderAnimator.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTSliderAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {
    var operation : UINavigationControllerOperation!
    var duration  : NSTimeInterval = 0.2
    
    internal var shadowView  : UIView?
    internal weak var destination : UIViewController!
    internal weak var source      : UIViewController!
    
    internal var curve             : UIViewAnimationCurve {
        get {
            return .EaseInOut
        }
    }
    
    internal var transitionContext : LTTransitionContext!
    
    internal var timeInterval      : NSTimeInterval!
    internal var interacting       : Bool!
    
    // MARK: - Public
    func updateInteractiveTransition(percentComplete: CGFloat) {
        let percent = max(0.0, min(1.0, percentComplete))
        
        timeInterval = duration * NSTimeInterval(percent)
        
        transitionContext.updateInteractiveTransition(percent)
        contextChangedPercentComplete(transitionContext, percentComplete: percent, completionHandler: nil)
    }
    
    func finishInteractiveTransition() {
        interacting = false
        let percentComplete : CGFloat = 1.0
        
        transitionContext.finishInteractiveTransition()
        transitionContext.updateInteractiveTransition(percentComplete)
        
        contextChangedPercentComplete(transitionContext, percentComplete: percentComplete) {completed in
            let context = self.transitionContext
            context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
    func cancelInteractiveTransition() {
        interacting = false
        let percentComplete : CGFloat = 1.0
        
        transitionContext.cancelInteractiveTransition()
        transitionContext.updateInteractiveTransition(percentComplete)
        
        contextChangedPercentComplete(transitionContext, percentComplete: percentComplete) {completed in
            let context = self.transitionContext
            context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
    // MARK: - Private
    func prepareAnimationForTransition(transitionContext: LTTransitionContext) {
        if let bounds = transitionContext.containerView()?.bounds as CGRect! {
            let shadow = UIView(frame: bounds)
            shadow.backgroundColor = UIColor.blackColor()
            
            shadowView = shadow
        }
        
        if let destinationController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as UIViewController! {
            let destinationView = destinationController.view
            destinationView.frame = transitionContext.initialFrameForViewController(destinationController)
            destination = destinationController
        }
        
        if let sourceController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UIViewController! {
            let sourceView = sourceController.view
            sourceView.frame = transitionContext.initialFrameForViewController(sourceController)
            source = sourceController
        }
        
        if let containerView = transitionContext.containerView() as UIView! {
            if .Push == operation {
                containerView.insertSubview(destination.view, aboveSubview: source.view)
                if let shadowView = shadowView as UIView! {
                    containerView.insertSubview(shadowView, aboveSubview: source.view)
                    shadowView.alpha = 0.0
                }
            } else if .Pop == operation {
                containerView.insertSubview(destination.view, belowSubview: source.view)
                if let shadowView = shadowView as UIView! {
                    containerView.insertSubview(shadowView, belowSubview: source.view)
                    shadowView.alpha = 1.0
                }
            }
        }
    }
    
    func contextChangedPercentComplete(transitionContext: LTTransitionContext, percentComplete: CGFloat, completionHandler:LTCompletionBlock?) {
        let duration = (transitionContext.isInteractive()) && (true == interacting) && (0 != timeInterval) ? 0 : transitionDuration(transitionContext) - timeInterval
        var options : UIViewAnimationOptions = .BeginFromCurrentState
        
        if .EaseInOut == curve {
            if .EaseIn == curve {
                options = options.union(.CurveEaseIn)
            } else if .EaseOut == curve {
                options = options.union(.CurveEaseOut)
            } else {
                options = [.CurveLinear, .BeginFromCurrentState]
            }
        }
        
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
            self.destination.view.frame = transitionContext.finalFrameForViewController(self.destination)
            self.source.view.frame = transitionContext.finalFrameForViewController(self.source)
            
            if let shadowView = self.shadowView as UIView! {
                shadowView.alpha = .Push == self.operation ? percentComplete : 1.0 - percentComplete
            }
            }, completion: completionHandler)

    }
    
    //MARK: - UIViewControllerAnimatedTransitioning
    func completionSpeed() -> CGFloat {
        return 1.0
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        let duration = self.duration / NSTimeInterval(completionSpeed());
        
        if let transitionContext = transitionContext as UIViewControllerContextTransitioning! {
            if transitionContext.isAnimated() && false == transitionContext.transitionWasCancelled() {
                return duration
            }
        }
        
        return 0.0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let context = transitionContext as? LTTransitionContext {
            prepareAnimationForTransition(context)
            contextChangedPercentComplete(context, percentComplete: 1.0) {complete in
                context.completeTransition(!context.transitionWasCancelled())
            }
        }
    }
    
    func animationEnded(transitionCompleted: Bool) {
        if let shadowView = shadowView as UIView! {
            shadowView.removeFromSuperview()
        }
        
        shadowView = nil
    }
    
    //MARK: - UIViewControllerInteractiveTransitioning
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let context = transitionContext as? LTTransitionContext {
            self.transitionContext = context
            interacting = true
            
            prepareAnimationForTransition(context)
        }
    }

}
