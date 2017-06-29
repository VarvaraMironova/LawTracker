//
//  LTTransitionContext.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

typealias LTCompletionBlock = (_ complete: Bool) -> Void

class LTTransitionContext: NSObject, UIViewControllerContextTransitioning {

    var completionBlock : LTCompletionBlock?
    weak var animator   : LTSliderAnimator?
    
    internal var viewControllers = [UITransitionContextViewControllerKey: UIViewController]()
    internal var container       : UIView
    internal var _animated       : Bool!
    internal var forward         : Bool!
    
    var cancelled                : Bool = false
    
    internal var percentComplete : CGFloat!
    
    init(source: UIViewController?, destination: UIViewController?, containerView: UIView, animated: Bool, forward: Bool) {
        if nil != source {
            viewControllers[UITransitionContextViewControllerKey.from] = source
        }
        
        if nil != destination {
            viewControllers[UITransitionContextViewControllerKey.to] = destination
        }
        
        self.container = containerView
        self._animated = animated
        self.forward = forward
        self.percentComplete = 1.0

        super.init()
    }
    
    // MARK: - UIViewControllerContextTransitioning
    var containerView : UIView {
        return container
    }
    
    var isAnimated : Bool {
        return _animated
    }
    
    var isInteractive : Bool {
        return nil != animator
    }
    
    var transitionWasCancelled : Bool {
        return cancelled
    }
    
    var presentationStyle : UIModalPresentationStyle {
        return .custom
    }
    
    var targetTransform : CGAffineTransform {
        return CGAffineTransform.identity
    }
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return viewControllers[key]
    }
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        switch key {
        case UITransitionContextViewKey.from:
            return viewController(forKey: UITransitionContextViewControllerKey.from)?.view
            
        case UITransitionContextViewKey.to:
            return viewController(forKey: UITransitionContextViewControllerKey.to)?.view
            
        default:
            return nil
        }
    }
    
    func initialFrame(for vc: UIViewController) -> CGRect {
        var result = CGRect.zero
        if let containerView = containerView as UIView! {
            if let key = allKeysForValue(viewControllers, value: vc).first {
                switch key {
                case UITransitionContextViewControllerKey.to:
                    result = containerView.bounds
                    
                    if false == forward {
                        result.origin.y -= result.size.height
                    }
                    
                    break
                    
                case UITransitionContextViewControllerKey.from:
                    result = containerView.bounds
                    break
                    
                default:
                    break
                }
            }
        }
        
        return result
    }
    
    func finalFrame(for vc: UIViewController) -> CGRect {
        var result = CGRect.zero
        if let containerView = containerView as UIView! {
            if let key = allKeysForValue(viewControllers, value: vc).first {
                switch key {
                case UITransitionContextViewControllerKey.from:
                    result = containerView.bounds
                    
                    if true == forward {
                        result.origin.y -= result.size.height
                    }
                    
                    break
                    
                case UITransitionContextViewControllerKey.to:
                    result = containerView.bounds
                    break
                    
                default:
                    break
                }
            }
        }
        
        let initialFrame = self.initialFrame(for: vc)
        let offsetX = result.minX - initialFrame.minX
        let offsetY = result.minY - initialFrame.minY
        let offsetWidth = result.width - initialFrame.width
        let offsetHeight = result.height - initialFrame.height
        
        let percents = isInteractive ? percentComplete : 1.0
        result = initialFrame.offsetBy(dx: offsetX * percents!, dy: offsetY * percents!)
        result.size.width += offsetWidth * percents!
        result.size.height += offsetHeight * percents!
        
        return result
    }
    
    func completeTransition(_ didComplete: Bool) {
        if let completionBlock = completionBlock as LTCompletionBlock! {
            completionBlock(didComplete)
        }
    }
    
    func updateInteractiveTransition(_ complete: CGFloat) {
        percentComplete = complete
    }

    @available(iOS 10.0, *)
    func pauseInteractiveTransition() {
        // FIXME?
    }
    
    func finishInteractiveTransition() {
        cancelled = false
    }
    
    func cancelInteractiveTransition() {
         cancelled = true
    }
    
    func allKeysForValue<K, V : Equatable>(_ dictionary: [K : V], value: V) -> [K] {
        return dictionary.filter{ $0.1 == value }.map{ $0.0 }
    }
    
}
