//
//  LTArrayViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/17/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTArrayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var cellClass: AnyClass {
        get {
            return LTTableViewCell.self
        }
    }
    
    var arrayModel: [AnyObject]!
    
    var rootView  : LTArrayRootView! {
        get {
            if isViewLoaded() && view.isKindOfClass(LTArrayRootView) {
                return view as! LTArrayRootView
            } else {
                return nil
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayModel.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(cellClass, indexPath: indexPath) as! LTTableViewCell
        let model = arrayModel[indexPath.row]
        cell.fillWithModel(model)
        
        return cell
    }

}
