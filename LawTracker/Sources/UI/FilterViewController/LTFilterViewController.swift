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
        static let Initiators = "ПІБ депутата або назва ініціатора"
        static let Committees = "Назва комітету"
        static let Laws       = "Номер або назва законопроекту"
    }
    
    weak var delegate: LTMainContentViewControllerViewController!
    
    var settingsModel = VTSettingModel()
    var filteredArray = [LTFilterModel]()
    
    var filters          : [LTFilterModel]!
    
    var selectedFilters  : [String]? {
        set {
            switch delegate.filterType {
            case .byCommittees:
                settingsModel.filters![VTSettingModel.Keys.Committees] = newValue
                
            case .byInitiators:
                settingsModel.filters![VTSettingModel.Keys.Initiators] = newValue
                
            case .byLaws:
                settingsModel.filters![VTSettingModel.Keys.Laws] = newValue
            }
            
            delegate.filtersDidApplied()
        }
        
        get {
            switch delegate.filterType {
            case .byCommittees:
                return settingsModel.filters![VTSettingModel.Keys.Committees]
                
            case .byInitiators:
                return settingsModel.filters![VTSettingModel.Keys.Initiators]
                
            case .byLaws:
                return settingsModel.filters![VTSettingModel.Keys.Laws]
            }
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
                return PlaceHolder.Laws
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
        
    //MARK: - Interface Handling
    @IBAction func onOkButton(sender: AnyObject) {
        //save filteredArray
        let selectedArray = filters.filter() { $0.selected == true }
        var filteredIds = [String]()
        
        for filterModel in selectedArray {
            filteredIds.append(filterModel.entity.id)
        }
        
        selectedFilters = filteredIds
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        //clear filters in Settings
        selectedFilters = []
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rootView.searchBar.text != "" || rootView.searchBar.selectedScopeButtonIndex > 0 {
            return filteredArray.count
        }
        
        return filters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTFilterTableViewCell", forIndexPath: indexPath) as! LTFilterTableViewCell
        if rootView.searchBar.text != "" || rootView.searchBar.selectedScopeButtonIndex > 0 {
            let model = filteredArray[indexPath.row]
            cell.fillWithModel(model)
        } else {
            let model = filters[indexPath.row]
            cell.fillWithModel(model)
        }
        
        return cell
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let searchBar = rootView.searchBar
        let array = searchBar.text != "" || searchBar.selectedScopeButtonIndex > 0 ? filteredArray : filters
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LTFilterTableViewCell
        let selectedModel = array[indexPath.row]
        selectedModel.selected = !cell.filtered
        
        filterContentForSearchText(searchBar.text!, scope: rootView.searchBar.selectedScopeButtonIndex)
    }
    
    //MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText, scope: rootView.searchBar.selectedScopeButtonIndex)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: selectedScope)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Private methods
    private func filterContentForSearchText(searchText: String, scope: Int = 0) {
        filteredArray = filters.filter({( filter : LTFilterModel) -> Bool in
            let category = filter.selected == true ? 1 : 2
            let categoryMatch = (scope == 0) || (category == scope)
            if searchText != "" {
                let containsInTitle = filter.entity.title.lowercaseString.containsString(searchText.lowercaseString)
                if let entity = filter.entity as? LTLawModel {
                    let containsInNumber = entity.number.lowercaseString.containsString(searchText.lowercaseString)
                    
                    return categoryMatch && (containsInTitle || containsInNumber)
                } else {
                    return categoryMatch && containsInTitle
                }
            } else {
                return categoryMatch
            }
        })
        
        rootView.tableView.reloadData()
    }
    
}
