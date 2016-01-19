//
//  LTFilterViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    struct PlaceHolder {
        static let Initiators = "Зазначте ініціатора"
        static let Committees = "Зазначте комітет"
        static let LawName    = "Зазначте назву законопроекта"
        static let LawNumber  = "Зазначте номер законопроекта"
    }
    
    weak var delegate: LTMainContentViewControllerViewController!
    
    var settingsModel    = VTSettingModel()
    
    var filteredArray   : [LTSectionModel]!
    var filters         : [LTSectionModel]!
    var selectedFilters : [String] {
        get {
            switch delegate.filterType {
            case .byCommittees:
                return settingsModel.committees
                
            case .byInitiators:
                return settingsModel.initiators
                
            case .byLaws:
                return settingsModel.laws
            }
        }
        
        set {
            switch delegate.filterType {
            case .byCommittees:
                settingsModel.committees = newValue
                
            case .byInitiators:
                settingsModel.initiators = newValue
                
            case .byLaws:
                settingsModel.laws = newValue
            }
        }
    }
    
    var selectedModel   : LTSectionModel? {
        didSet {
            rootView.fillSearchBar(selectedModel!)
        }
    }
    
    var placeholderString: String {
        get {
            switch delegate.filterType {
            case .byCommittees:
                return PlaceHolder.Committees
            
            case .byInitiators:
                return PlaceHolder.Initiators
                
            case .byLaws:
                return PlaceHolder.LawName
            }
        }
    }
    
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
        //clear filters in Settings
        selectedFilters = []
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1:
            return selectedFilters.count
        
        case 2:
            if rootView.searchBar.text != "" {
                return filteredArray.count
            }
            
            return filters.count
            
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTFilterTableViewCell", forIndexPath: indexPath) as! LTFilterTableViewCell
        switch tableView.tag {
        case 1:
            let id = selectedFilters[indexPath.row]
            for model in filters {
//                if model.id == id {
                    cell.fillWithModel(model)
//                }
            }
            
            break
            
        case 2:
            if rootView.searchBar.text != "" {
                let model = filteredArray[indexPath.row]
                cell.fillWithModel(model)
            } else {
                let model = filters[indexPath.row]
                cell.fillWithModel(model)
            }
            
            break
            
        default:
            break
        }
        
        return cell
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 2 {
            let selectedModel = filters[indexPath.row]
//            selectedFilters.append(selectedModel.id)
            let index = filters.indexOf({$0.title == selectedModel.title})
            filters.removeAtIndex(index!)
            
            rootView.tableView.reloadData()
            rootView.filteredTableView.reloadData()
            rootView.fitTableViewHeight()
            
            rootView.searchBar.text = ""
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch tableView.tag {
        case 1:
            if .Delete == editingStyle {
                let id = selectedFilters[indexPath.row]
                selectedFilters.removeAtIndex(indexPath.row)
                rootView.filteredTableView.reloadData()
                rootView.fitTableViewHeight()
                
                for model in filters {
//                    if model.id == id {
                        filters.append(model)
                        rootView.tableView.reloadData()
//                    }
                }
            }
            
            break
            
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        switch tableView.tag {
        case 1:
            return .Delete
            
        default:
            return .None
        }
    }
    
    //MARK: - UISearchBarDelegate
    func searchBarShouldReturn(searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    //MARK: - Private methods
    func filterContentForSearchText(searchText: String) {
        filteredArray = filters.filter({( filter : LTSectionModel) -> Bool in
            return filter.title.lowercaseString.containsString(searchText.lowercaseString)
        })
        
        rootView.tableView.reloadData()
    }
}
