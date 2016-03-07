//
//  LTMenuViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/11/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

let kLTChesnoURL = "http://www.chesno.org"

enum LTMenuCells: Int {
    case Manual = 0,
    WebSite     = 1
    
    static let cellTypes = [Manual, WebSite]
};

class LTMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: LTNewsFeedViewController!
    
    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LTMenuCells.cellTypes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTMenuTableViewCell", forIndexPath: indexPath) as! LTMenuTableViewCell
        var string = ""
        switch indexPath.row {
        case 0:
            string = "Мануал"
            break
            
        case 1:
            string = "На веб-сайт Чесно"
            break
            
        default:
            break
        }
        
        cell.fill(string)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate.rootView!.hideMenu(){[weak storyboard = self.storyboard, weak navigationController = navigationController] (finished) in
            if finished {
                switch indexPath.row {
                case 0:
                    dispatch_async(dispatch_get_main_queue()) {
                        let helpViewController = storyboard!.instantiateViewControllerWithIdentifier("LTHelpController") as! LTHelpController
                        navigationController!.presentViewController(helpViewController, animated: true, completion: nil)
                        //navigationController!.pushViewController(helpViewController, animated: true)
                    }
                    
                    break
                    
                case 1:
                    let url = NSURL(string: kLTChesnoURL)
                    let app = UIApplication.sharedApplication()
                    if app.canOpenURL(url!) {
                        app.openURL(url!)
                    }
                    
                    break
                    
                default:
                    break
                }
            }
        }
    }

}
