//
//  LTTransitionContext.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

typealias LTCompletionBlock = (complete: Bool!) -> Void

class LTTransitionContext: NSObject, UIViewControllerContextTransitioning {
    var completionBlock : LTCompletionBlock?
    weak var animator   : LTSliderAnimator!
    
    internal var viewControllers = [String: UIViewController]()
    internal var container       : UIView?
    internal var animated        : Bool!
    internal var forward         : Bool!
    
    var cancelled                : Bool = false
    
    internal var interactive   : Bool {
        return nil != animator
    }
    
    internal var percentComplete : CGFloat {
        set {
            self.percentComplete = newValue
        }
        
        get {
            return isInteractive() ? self.percentComplete : 1.0
        }
    }
    
    init(source: UIViewController?, destination: UIViewController?, containerView: UIView, animated: Bool, forward: Bool) {
        super.init()
        
        if nil != source {
            viewControllers[UITransitionContextFromViewControllerKey] = source
        }
        
        if nil != destination {
            viewControllers[UITransitionContextToViewControllerKey] = destination
        }
        
        self.container = containerView
        self.animated = animated
        self.forward = forward
        self.percentComplete = 1.0
    }
    
    // MARK: - UIViewControllerContextTransitioning
    func containerView() -> UIView? {
        return container
    }
    
    func isAnimated() -> Bool {
        return animated
    }
    
    func isInteractive() -> Bool {
        return interactive
    }
    
    func transitionWasCancelled() -> Bool {
        return cancelled
    }
    
    func presentationStyle() -> UIModalPresentationStyle {
        return .Custom
    }
    
    func targetTransform() -> CGAffineTransform {
        return CGAffineTransformIdentity
    }
    
    func viewControllerForKey(key: String) -> UIViewController? {
        return viewControllers[key]
    }
    
    func viewForKey(key: String) -> UIView? {
        switch key {
        case UITransitionContextFromViewKey:
            return viewControllerForKey(key)?.view
            
        case UITransitionContextToViewKey:
            return viewControllerForKey(key)?.view
            
        default:
            return nil
        }
    }
    
    func initialFrameForViewController(vc: UIViewController) -> CGRect {
        var result = CGRectZero
        if let containerView = containerView() as UIView! {
            if let key = allKeysForValue(viewControllers, value: vc).first as String! {
                switch key {
                case UITransitionContextFromViewKey:
                    result = containerView.bounds
                    
                    if true == forward {
                        result.origin.y -= result.size.height
                    }
                    
                    break
                    
                case UITransitionContextToViewKey:
                    result = containerView.bounds
                    break
                    
                default:
                    break
                }
            }
        }
        
        return result
    }
    
    func finalFrameForViewController(vc: UIViewController) -> CGRect {
        var result = CGRectZero
        if let containerView = containerView() as UIView! {
            if let key = allKeysForValue(viewControllers, value: vc).first as String! {
                switch key {
                case UITransitionContextFromViewKey:
                    result = containerView.bounds
                    
                    if true == forward {
                        result.origin.y -= result.size.height
                    }
                    
                    break
                    
                case UITransitionContextToViewKey:
                    result = containerView.bounds
                    break
                    
                default:
                    break
                }
            }
        }
        
        let initialFrame = initialFrameForViewController(vc)
        let offsetX = CGRectGetMinX(result) - CGRectGetMinX(initialFrame)
        let offsetY = CGRectGetMinY(result) - CGRectGetMinY(initialFrame)
        let offsetWidth = CGRectGetWidth(result) - CGRectGetWidth(initialFrame)
        let offsetHeight = CGRectGetHeight(result) - CGRectGetHeight(initialFrame)
        
        result = CGRectOffset(initialFrame, offsetX * percentComplete, offsetY * percentComplete)
        result.size.width += offsetWidth * percentComplete
        result.size.height += offsetHeight * percentComplete
        
        return result
    }
    
    func completeTransition(didComplete: Bool) {
        if let completionBlock = completionBlock as LTCompletionBlock! {
            completionBlock(complete: didComplete)
        }
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        self.percentComplete = percentComplete
    }
    
    func finishInteractiveTransition() {
        cancelled = true
    }
    
    func cancelInteractiveTransition() {
         cancelled = true
    }
    
    func allKeysForValue<K, V : Equatable>(dictionary: [K : V], value: V) -> [K] {
        return dictionary.filter{ $0.1 == value }.map{ $0.0 }
    }
    
}
