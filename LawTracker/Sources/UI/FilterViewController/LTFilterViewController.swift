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
    
    var filterDelegate: LTFilterDelegate?
    
    var filters      : [LTSectionModel]?
    var filteredArray = [LTSectionModel]()
    var type         : LTType!
    
    var placeholderString: String {
        get {
            switch type.rawValue {
            case 0:
                return PlaceHolder.Committees
            
            case 1:
                return PlaceHolder.Initiators
                
            default:
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
        setFilters {[unowned self] (finished) -> Void in
            if finished {
                dispatch_async(dispatch_get_main_queue()) {
                    if let filterDelegate = self.filterDelegate {
                        filterDelegate.filtersDidApplied()
                    }
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        //clear filters in Settings
        if let filters = filters as [LTSectionModel]! {
            for sectionModel in filters {
                for filter in sectionModel.filters {
                    filter.entity.filterSet = false
                }
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            if let filterDelegate = self.filterDelegate {
                filterDelegate.filtersDidApplied()
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func onSelectAllButton(sender: AnyObject) {
        rootView.endEditing(true)
        
        if let filters = filters as [LTSectionModel]! {
            let select = !rootView.selectAllButton.on
            rootView.selectAllButton.on = select
            
            for sectionModel in filters {
                for filterModel in sectionModel.filters {
                    if let committeeModel = filterModel.entity as? LTCommitteeModel {
                        if committeeModel.expired {
                            filterModel.selected = false
                        } else {
                            filterModel.selected = select
                        }
                    } else {
                        filterModel.selected = select
                    }
                }
            }
            
            filterContentForSearchText("", scope: rootView.searchBar.selectedScopeButtonIndex)
            
            rootView.tableView.reloadData()
        }
    }
    
    func headerTapped() {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView] in
            if let filters = self.filters as [LTSectionModel]! {
                rootView!.endEditing(true)
                let deputiesArray = filters.filter(){ $0.title == "Народні депутати України" }.first
                if let deputies = deputiesArray as LTSectionModel! {
                    for model in deputies.filters {
                        model.selected = !model.selected
                    }
                }
                
                let searchBar = rootView!.searchBar
                self.filterContentForSearchText(searchBar.text!, scope: searchBar.selectedScopeButtonIndex)
            }
        }
    }
    
    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filters = filters as [LTSectionModel]! {
            let sectionModel = rootView.searchBarActive ? filteredArray[section] : filters[section]
            
            return sectionModel.filters.count
        }
        
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let filters = filters as [LTSectionModel]! {
            return rootView.searchBarActive ? filteredArray.count : filters.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTFilterTableViewCell", forIndexPath: indexPath) as! LTFilterTableViewCell
        if let filters = filters as [LTSectionModel]! {
            let model = rootView.searchBarActive ? filteredArray[indexPath.section].filters[indexPath.row] : filters[indexPath.section].filters[indexPath.row]
            
            cell.fillWithModel(model)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let filters = filters as [LTSectionModel]! {
            return rootView.searchBarActive ? filteredArray[section].title : filters[section].title
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let filters = filters as [LTSectionModel]! {
            let headerView = LTCellHeaderView.headerView() as LTCellHeaderView
            let title = rootView.searchBarActive ? filteredArray[section].title : filters[section].title
            headerView.fillWithString(title)
            let button = UIButton()
            button.frame = headerView.frame
            button.addTarget(self, action: "headerTapped", forControlEvents: .TouchUpInside)
            headerView.addSubview(button)
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let filters = filters as [LTSectionModel]! {
            let title = rootView.searchBarActive ? filteredArray[section].title : filters[section].title
            
            return title == "" ? 0.1 : 30.0
        }
        
        return 0.0
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView] in
            rootView!.endEditing(true)
            if let filters = self.filters as [LTSectionModel]! {
                let searchBar = rootView!.searchBar
                let array = rootView!.searchBarActive ? self.filteredArray[indexPath.section].filters : filters[indexPath.section].filters
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! LTFilterTableViewCell
                let selectedModel = array[indexPath.row]
                selectedModel.selected = !cell.filtered
                
                self.filterContentForSearchText(searchBar.text!, scope: searchBar.selectedScopeButtonIndex)
            }
        }
    }
    
    //MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            self.filterContentForSearchText(searchText, scope: searchBar.selectedScopeButtonIndex)
        }
        
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            self.filterContentForSearchText(searchBar.text!, scope: selectedScope)
        }
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        dispatch_async(dispatch_get_main_queue()) {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dispatch_async(dispatch_get_main_queue()) {
            searchBar.resignFirstResponder()
        }
        
    }
    
    //MARK: - Private methods
    private func filterContentForSearchText(searchText: String, scope: Int = 0) {
        if let filters = filters as [LTSectionModel]! {
            filteredArray = [LTSectionModel]()
            for sectionModel in filters {
                let filters = sectionModel.filters.filter({( filter : LTFilterCellModel) -> Bool in
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
                    let filteredSection = LTSectionModel()
                    filteredSection.title = sectionModel.title
                    filteredSection.filters = filters
                    
                    filteredArray.append(filteredSection)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {[weak rootView = rootView] in
                rootView!.tableView.reloadData()
            }
        }
    }
    
    private func setFilters(completionHandler:(finished: Bool) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        dispatch_async(queue) {
            if let filters = self.filters as [LTSectionModel]! {
                for sectionModel in filters {
                    for filter in sectionModel.filters {
                        filter.entity.filterSet = filter.selected
                    }
                }
                
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
            completionHandler(finished: true)
        }
    }
    
}
