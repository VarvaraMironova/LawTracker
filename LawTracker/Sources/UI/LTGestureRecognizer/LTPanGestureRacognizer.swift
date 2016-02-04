//
//  LTPanGestureRacognizer.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

enum LTPanDirection: Int {
    case Unknown = 0,
    Right,
    Left,
    Up,
    Down
    
    static let cellTypes = [Unknown, Right, Left, Up, Down]
};

class LTPanGestureRacognizer: UIPanGestureRecognizer {
    var direction      : LTPanDirection!
    var startLocation  : CGPoint!
    
    override var state : UIGestureRecognizerState {
        set {
            if .Began == newValue {
                let translation = translationInView(view)
                direction = CGPointEqualToPoint(CGPointZero, translation) ? directionForTranslation(velocityInView(view)) : directionForTranslation(translation)
                startLocation = locationInView(view)
            }
            
            self.state = newValue
        }
        
        get {
            return self.state
        }
    }
    
    //MARK: - Public methods
    func reset() {
        direction = .Unknown
        startLocation = CGPointZero
    }
    
    //MARK: - Private methods
    func directionForTranslation(translation: CGPoint) -> LTPanDirection {
        let size = CGSizeMake(translation.x, translation.y)
        let verticalOffset = size.height
        let horizontalOffset = size.width
        
        if verticalOffset < horizontalOffset {
            return translation.x > 0 ? .Right : .Left
        } else if verticalOffset > horizontalOffset {
            return translation.y > 0 ? .Down : .Up
        }

        return .Unknown
    }
}
