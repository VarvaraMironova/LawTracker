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
    
    weak var delegate: LTNewsFeedViewController!
    
    var settingsModel = VTSettingModel()
    var filteredArray = [LTSectionModel]()
    
    var filters          : [LTSectionModel]!
    
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        rootView.fillSearchBarPlaceholder(placeholderString)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        rootView.endEditing(true)
    }
        
    //MARK: - Interface Handling
    @IBAction func onOkButton(sender: AnyObject) {
        //save filteredArray
        var selectedArray = [LTFilterModel]()
        for sectionModel in filters {
            selectedArray.appendContentsOf(sectionModel.filters.filter() { $0.selected == true })
        }
        
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
    
    @IBAction func onSelectAllButton(sender: AnyObject) {
        rootView.endEditing(true)
        
        let select = rootView.selectAllButton.on
        rootView.selectAllButton.on = !select
        
        for sectionModel in filters {
            for filterModel in sectionModel.filters {
                if let committeeModel = filterModel.entity as? LTCommitteeModel {
                    if let _ = committeeModel.ends as NSDate! {
                        filterModel.selected = false
                    } else {
                        filterModel.selected = !select
                    }
                } else {
                    filterModel.selected = !select
                }
            }
        }
        
        filterContentForSearchText("", scope: rootView.searchBar.selectedScopeButtonIndex)
        
        rootView.tableView.reloadData()
    }
    
    func headerTapped() {
        dispatch_async(dispatch_get_main_queue()) {
            self.rootView.endEditing(true)
            let deputiesArray = self.filters.filter(){ $0.title == "Народні депутати України" }.first
            if let deputies = deputiesArray as LTSectionModel! {
                for model in deputies.filters {
                    model.selected = !model.selected
                }
            }
            
            self.filterContentForSearchText(self.rootView.searchBar.text!, scope: self.rootView.searchBar.selectedScopeButtonIndex)
        }
    }
    
    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionModel = rootView.searchBarActive ? filteredArray[section] : filters[section]
        
        return sectionModel.filters.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rootView.searchBarActive ? filteredArray.count : filters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTFilterTableViewCell", forIndexPath: indexPath) as! LTFilterTableViewCell
        let model = rootView.searchBarActive ? filteredArray[indexPath.section].filters[indexPath.row] : filters[indexPath.section].filters[indexPath.row]
        
        cell.fillWithModel(model)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return rootView.searchBarActive ? filteredArray[section].title : filters[section].title
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = LTCellHeaderView.headerView() as LTCellHeaderView
        let title = rootView.searchBarActive ? filteredArray[section].title : filters[section].title
        headerView.fillWithString(title)
        let button = UIButton()
        button.frame = headerView.frame
        button.addTarget(self, action: "headerTapped", forControlEvents: .TouchUpInside)
        headerView.addSubview(button)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let title = rootView.searchBarActive ? filteredArray[section].title : filters[section].title
        
        return title == "" ? 0.1 : 30.0
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rootView.endEditing(true)
        let searchBar = rootView.searchBar
        let array = rootView.searchBarActive ? filteredArray[indexPath.section].filters : filters[indexPath.section].filters
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
        filteredArray = [LTSectionModel]()
        for sectionModel in filters {
            let filters = sectionModel.filters.filter({( filter : LTFilterModel) -> Bool in
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
            
            if filters.count > 0 {
                let filteredSection = LTSectionModel(title: sectionModel.title)
                filteredSection.filters = filters
                
                filteredArray.append(filteredSection)
            }
        }
        
        rootView.tableView.reloadData()
    }
    
}
