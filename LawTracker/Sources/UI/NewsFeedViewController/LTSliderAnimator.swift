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
    var duration  : TimeInterval = 0.2
    
    internal var shadowView  : UIView?
    internal weak var destination : UIViewController!
    internal weak var source      : UIViewController!
    
    internal var curve             : UIViewAnimationCurve {
        get {
            return .easeInOut
        }
    }
    
    internal var transitionContext : LTTransitionContext!
    
    internal var timeInterval      : TimeInterval!
    internal var interacting       : Bool!
    
    // MARK: - Public
    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        let percent = max(0.0, min(1.0, percentComplete))
        
        timeInterval = duration * TimeInterval(percent)
        
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
            context?.completeTransition(context!.transitionWasCancelled)
        }
    }
    
    func cancelInteractiveTransition() {
        interacting = false
        let percentComplete : CGFloat = 1.0
        
        transitionContext.cancelInteractiveTransition()
        transitionContext.updateInteractiveTransition(percentComplete)
        
        contextChangedPercentComplete(transitionContext, percentComplete: percentComplete) {completed in
            let context = self.transitionContext
            context?.completeTransition(context!.transitionWasCancelled)
        }
    }
    
    // MARK: - Private
    func prepareAnimationForTransition(_ transitionContext: LTTransitionContext) {
        if let bounds = transitionContext.containerView.bounds as CGRect! {
            let shadow = UIView(frame: bounds)
            shadow.backgroundColor = UIColor.black
            
            shadowView = shadow
        }
        
        if let destinationController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as UIViewController! {
            let destinationView = destinationController.view
            destinationView?.frame = transitionContext.initialFrame(for: destinationController)
            destination = destinationController
        }
        
        if let sourceController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as UIViewController! {
            let sourceView = sourceController.view
            sourceView?.frame = transitionContext.initialFrame(for: sourceController)
            source = sourceController
        }

        let containerView = transitionContext.containerView
        if .push == operation {
            containerView.insertSubview(destination.view, aboveSubview: source.view)
            if let shadowView = shadowView as UIView! {
                containerView.insertSubview(shadowView, aboveSubview: source.view)
                shadowView.alpha = 0.0
            }
        } else if .pop == operation {
            containerView.insertSubview(destination.view, belowSubview: source.view)
            if let shadowView = shadowView as UIView! {
                containerView.insertSubview(shadowView, belowSubview: source.view)
                shadowView.alpha = 1.0
            }
        }
    }
    
    func contextChangedPercentComplete(_ transitionContext: LTTransitionContext, percentComplete: CGFloat, completionHandler:LTCompletionBlock?) {
        let duration = (transitionContext.isInteractive) && (true == interacting) && (0 != timeInterval) ? 0 : transitionDuration(using: transitionContext) - timeInterval
        var options : UIViewAnimationOptions = .beginFromCurrentState
        
        if .easeInOut == curve {
            if .easeIn == curve {
                options = options.union(.curveEaseIn)
            } else if .easeOut == curve {
                options = options.union(.curveEaseOut)
            } else {
                options = [.curveLinear, .beginFromCurrentState]
            }
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.destination.view.frame = transitionContext.finalFrame(for: self.destination)
            self.source.view.frame = transitionContext.finalFrame(for: self.source)
            
            if let shadowView = self.shadowView as UIView! {
                shadowView.alpha = .push == self.operation ? percentComplete : 1.0 - percentComplete
            }
            }, completion: completionHandler)

    }
    
    //MARK: - UIViewControllerAnimatedTransitioning
    var completionSpeed : CGFloat {
        return 1.0
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let duration = self.duration / TimeInterval(completionSpeed);
        
        if let transitionContext = transitionContext as UIViewControllerContextTransitioning! {
            if transitionContext.isAnimated && false == transitionContext.transitionWasCancelled {
                return duration
            }
        }
        
        return 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let context = transitionContext as? LTTransitionContext {
            prepareAnimationForTransition(context)
            contextChangedPercentComplete(context, percentComplete: 1.0) {complete in
                context.completeTransition(context.transitionWasCancelled)
            }
        }
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        if let shadowView = shadowView as UIView! {
            shadowView.removeFromSuperview()
        }
        
        shadowView = nil
    }
    
    //MARK: - UIViewControllerInteractiveTransitioning
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if let context = transitionContext as? LTTransitionContext {
            self.transitionContext = context
            interacting = true
            
            prepareAnimationForTransition(context)
        }
    }

}
