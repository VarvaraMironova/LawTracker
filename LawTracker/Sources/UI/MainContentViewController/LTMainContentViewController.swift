//
//  LTMainContentViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTMainContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var shownDate  : NSDate!
    var arrayModel : LTChangesModel? {
        didSet {
            rootView.contentTableView.reloadData()
        }
    }
    
    var rootView   : LTMainContentRootView! {
        get {
            if isViewLoaded() && view.isKindOfClass(LTMainContentRootView) {
                return view as! LTMainContentRootView
            } else {
                return nil
            }
        }
    }
    
    var cellClass : AnyClass {
        get {
            return LTMainContentTableViewCell.self
        }
    }
    
    //MARK: - View Life Cycle
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
        
    //MARK: - gestureRecognizers
    @IBAction func onLongTapGestureRecognizer(sender: UILongPressGestureRecognizer) {
        //find indexPath for selected row
        let tableView = rootView.contentTableView
        let tapLocation = sender.locationInView(tableView)
        if let indexPath = tableView.indexPathForRowAtPoint(tapLocation) as NSIndexPath! {
            //model for selected row
            if nil == arrayModel {
                return
            }
            
            let section = arrayModel!.changes[indexPath.section]
            let model = section.changes[indexPath.row]
            //complete sharing text
            let law = model.law
            var initiators = [String]()
            for initiator in law.initiators {
                initiators.append(initiator.title!!)
            }
            
            let titles:[String] = [model.date.longString(), "Статус:", model.title, "Законопроект:", law.title, "Ініційовано:", initiators.joinWithSeparator(", "), "Головний комітет:", (law.committee.title)]
            let text = titles.joinWithSeparator("\n")
            let url = model.law.url
            
            let shareItems = [text, url]
            
            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            if presentedViewController != nil {
                return
            }
            
            presentViewController(activityViewController, animated: true, completion: nil)
            
            if UI_USER_INTERFACE_IDIOM() == .Pad {
                if let popoverViewController = activityViewController.popoverPresentationController {
                    popoverViewController.permittedArrowDirections = .Any
                    popoverViewController.sourceRect = CGRectMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 4, 0, 0)
                    popoverViewController.sourceView = rootView
                }
            }
        }
    }
    
    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arrayModel = arrayModel as LTChangesModel! {
            return arrayModel.changes[section].changes.count
        } else {
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let model = arrayModel {
            let count = model.changes.count
            rootView.noSubscriptionsLabel.hidden = count > 0
            rootView.noSubscriptionsLabel.text = "Немає данних щодо змін статусів законопроектів на цей день."
            
            return count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(cellClass, indexPath: indexPath) as! LTMainContentTableViewCell
        
        if let arrayModel = arrayModel as LTChangesModel! {
            let model = arrayModel.changes[indexPath.section]
            cell.fillWithModel(model.changes[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let arrayModel = arrayModel as LTChangesModel! {
            return arrayModel.changes[section].title
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let arrayModel = arrayModel as LTChangesModel! {
            let headerView = LTCellHeaderView.headerView() as LTCellHeaderView
            headerView.fillWithString(arrayModel.changes[section].title)
            
            return headerView
        }
        
        return nil
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let arrayModel = arrayModel as LTChangesModel! {
            let sectionModel = arrayModel.changes[indexPath.section]
            let changeModel = sectionModel.changes[indexPath.row]
            if let url = NSURL(string: changeModel.law.url) as NSURL! {
                let app = UIApplication.sharedApplication()
                if app.canOpenURL(url) {
                    app.openURL(url)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let arrayModel = arrayModel as LTChangesModel! {
            let changes = arrayModel.changes[indexPath.section].changes
            let changeModel = changes[indexPath.row]
            let width = CGRectGetWidth(tableView.frame) - 20.0
            let descriptionFont = UIFont(name: "Arial-BoldMT", size: 14.0)
            let lawNameHeight = changeModel.law.title.getHeight(width, font: descriptionFont!)
            let descriptionHeight = changeModel.title.getHeight(width, font: descriptionFont!)
            
            return lawNameHeight + descriptionHeight + 20.0
        }
        
        return 0.0
    }

}
