//
//  LTPanGestureRacognizer.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

enum LTPanDirection: Int {
    case unknown = 0,
    right,
    left,
    up,
    down
    
    static let cellTypes = [unknown, right, left, up, down]
};

class LTPanGestureRacognizer: UIPanGestureRecognizer {
    var direction      : LTPanDirection!
    var startLocation  : CGPoint!
    
    //MARK: - Public methods
    func changeDirection() {
        let translation = self.translation(in: view)
        direction = CGPoint.zero.equalTo(translation) ? directionForTranslation(velocity(in: view)) : directionForTranslation(translation)
        startLocation = location(in: view)
    }
    
    func reset() {
        direction = .unknown
        startLocation = CGPoint.zero
    }
    
    //MARK: - Private methods
    func directionForTranslation(_ translation: CGPoint) -> LTPanDirection {
        let frame = CGRect(x: 0, y: 0, width: translation.x, height: translation.y)
        let verticalOffset = frame.height
        let horizontalOffset = frame.width
        
        if verticalOffset < horizontalOffset {
            return translation.x > 0 ? .right : .left
        } else if verticalOffset > horizontalOffset {
            return translation.y > 0 ? .down : .up
        }

        return .unknown
    }
}
