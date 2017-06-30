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
            if isViewLoaded && view.isKind(of: LTFilterRootView.self) {
                return view as? LTFilterRootView
            } else {
                return nil
            }
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rootView.fillSearchBarPlaceholder(placeholderString)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        rootView.endEditing(true)
    }
        
    //MARK: - Interface Handling
    @IBAction func onOkButton(_ sender: AnyObject) {
        setFilters {[unowned self] (finished) -> Void in
            if finished {
                DispatchQueue.main.async {
                    if let filterDelegate = self.filterDelegate {
                        filterDelegate.filtersDidApplied()
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        //clear filters in Settings
        if let filters = filters as [LTSectionModel]! {
            for sectionModel in filters {
                for filter in sectionModel.filters {
                    filter.entity.filterSet = false
                }
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
        DispatchQueue.main.async {[unowned self] in
            if let filterDelegate = self.filterDelegate {
                filterDelegate.filtersDidApplied()
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onSelectAllButton(_ sender: AnyObject) {
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
        DispatchQueue.main.async {[unowned self, weak rootView = rootView] in
            if let filters = self.filters as [LTSectionModel]! {
                rootView!.endEditing(true)
                let deputiesArray = filters.filter(){ $0.title == "Народні депутати України" }.first
                if let deputies = deputiesArray as LTSectionModel! {
                    for model in deputies.filters {
                        model.selected = !model.selected
                    }
                }
                
                let searchBar = rootView!.searchBar
                self.filterContentForSearchText((searchBar?.text!)!, scope: (searchBar?.selectedScopeButtonIndex)!)
            }
        }
    }
    
    //MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filters = filters as [LTSectionModel]! {
            let sectionModel = rootView.searchBarActive ? filteredArray[section] : filters[section]
            
            return sectionModel.filters.count
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let filters = filters as [LTSectionModel]! {
            return rootView.searchBarActive ? filteredArray.count : filters.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LTFilterTableViewCell", for: indexPath) as! LTFilterTableViewCell
        if let filters = filters as [LTSectionModel]! {
            let model = rootView.searchBarActive ? filteredArray[indexPath.section].filters[indexPath.row] : filters[indexPath.section].filters[indexPath.row]
            
            cell.fillWithModel(model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let filters = filters as [LTSectionModel]! {
            return rootView.searchBarActive ? filteredArray[section].title : filters[section].title
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let filters = filters as [LTSectionModel]! {
            let headerView = LTCellHeaderView.headerView() as LTCellHeaderView
            let title = rootView.searchBarActive ? filteredArray[section].title : filters[section].title
            headerView.fillWithString(title)
            let button = UIButton()
            button.frame = headerView.frame
            button.addTarget(self, action: #selector(LTFilterViewController.headerTapped), for: .touchUpInside)
            headerView.addSubview(button)
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let filters = filters as [LTSectionModel]! {
            let title = rootView.searchBarActive ? filteredArray[section].title : filters[section].title
            
            return title == "" ? 0.1 : 30.0
        }
        
        return 0.0
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {[unowned self, weak rootView = rootView] in
            rootView!.endEditing(true)
            if let filters = self.filters as [LTSectionModel]! {
                let searchBar = rootView!.searchBar
                let array = rootView!.searchBarActive ? self.filteredArray[indexPath.section].filters : filters[indexPath.section].filters
                let cell = tableView.cellForRow(at: indexPath) as! LTFilterTableViewCell
                let selectedModel = array[indexPath.row]
                selectedModel.selected = !cell.filtered
                
                self.filterContentForSearchText((searchBar?.text!)!, scope: (searchBar?.selectedScopeButtonIndex)!)
            }
        }
    }
    
    //MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.async {[unowned self] in
            self.filterContentForSearchText(searchText, scope: searchBar.selectedScopeButtonIndex)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        DispatchQueue.main.async {[unowned self] in
            self.filterContentForSearchText(searchBar.text!, scope: selectedScope)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    //MARK: - Private methods
    fileprivate func filterContentForSearchText(_ searchText: String, scope: Int = 0) {
        if let filters = filters as [LTSectionModel]! {
            filteredArray = [LTSectionModel]()
            for sectionModel in filters {
                let filters = sectionModel.filters.filter({( filter : LTFilterCellModel) -> Bool in
                    let category = filter.selected == true ? 1 : 2
                    let categoryMatch = (scope == 0) || (category == scope)
                    if searchText != "" {
                        let containsInTitle = filter.entity.title.lowercased().contains(searchText.lowercased())
                        if let entity = filter.entity as? LTLawModel {
                            let containsInNumber = entity.number.lowercased().contains(searchText.lowercased())
                            
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
            
            DispatchQueue.main.async {[weak rootView = rootView] in
                rootView!.tableView.reloadData()
            }
        }
    }
    
    fileprivate func setFilters(_ completionHandler:@escaping (_ finished: Bool) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        queue.async {
            if let filters = self.filters as [LTSectionModel]! {
                for sectionModel in filters {
                    for filter in sectionModel.filters {
                        filter.entity.filterSet = filter.selected
                    }
                }
                
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
            completionHandler(true)
        }
    }
    
}
