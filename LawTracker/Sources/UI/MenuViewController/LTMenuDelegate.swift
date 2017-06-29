//
//  LTMenuDelegate.swift
//  LawTracker
//
//  Created by Varvara Mironova on 3/18/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

protocol LTMenuDelegate {
    func hideMenu(_ completionHandler: @escaping (_ finished: Bool) -> Void)
}
