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
    WebSite     = 1,
    About       = 2
    
    static let cellTypes = [Manual, WebSite, About]
};

class LTMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: LTMainContentViewControllerViewController!
    
    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LTMenuCells.cellTypes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTMenuTableViewCell", forIndexPath: indexPath) as! LTMenuTableViewCell
        var string = ""
        switch indexPath.row {
        case 0:
            string = "Manual"
            break
            
        case 1:
            string = "To web-site Chesno"
            break
            
        case 2:
            string = "About"
            break
            
        default:
            break
        }
        
        cell.fill(string)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate.rootView.hideMenu(){finished in
            if finished {
                let view = self.delegate.rootView
                switch indexPath.row {
                case 0:
                    view.showHelpView()
                    
                    break
                    
                case 1:
                    let url = NSURL(string: kLTChesnoURL)
                    let app = UIApplication.sharedApplication()
                    if app.canOpenURL(url!) {
                        app.openURL(url!)
                    }
                    
                    break
                    
                case 2:
                    view.showAboutView()
                    break
                    
                default:
                    break
                }
            }
        }
    }

}
