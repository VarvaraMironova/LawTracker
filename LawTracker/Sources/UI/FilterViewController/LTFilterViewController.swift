//
//  LTFilterViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    weak var delegate: LTMainContentViewControllerViewController!
    
    var filteredArray: [LTSectionModel]!
    var searchArray  : [LTSectionModel]!
    var selectedModel: LTSectionModel? {
        didSet {
            rootView.fillSearchBar(selectedModel!)
        }
    }
    
    var placeholderString: String!
    
    var rootView: LTFilterRootView! {
        get {
            if isViewLoaded() && view.isKindOfClass(LTFilterRootView) {
                return view as? LTFilterRootView
            } else {
                return nil
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        rootView.fillSearchBarPlaceholder(placeholderString)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - Interface Handling
    
    @IBAction func onOkButton(sender: AnyObject) {
        //save filteredArray
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1:
            return filteredArray.count
        
        case 2:
            return searchArray.count
            
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTFilterTableViewCell", forIndexPath: indexPath) as! LTFilterTableViewCell
        
        let model = tableView.tag == 1 ? filteredArray[indexPath.row] : searchArray[indexPath.row]
        cell.fillWithModel(model)
        
        return cell
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 2 {
            selectedModel = searchArray[indexPath.row]
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch tableView.tag {
        case 1:
            if .Delete == editingStyle {
                filteredArray.removeAtIndex(indexPath.row)
            }
            
            break
            
        default:
            break
        }
    }
    
    //MARK: - UISearchBarDelegate
    func searchBarDidEndEditing(searchBar: UISearchBar) {
        //find model with description == textField.text in searchArray and add it to filteredArray
        //if there in no model with description == textField.text -> show alert
        if let selectedModel = selectedModel as LTSectionModel! {
            filteredArray.append(selectedModel)
        }
    }
    
    func searchBarShouldReturn(searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        
        return true
    }
}
