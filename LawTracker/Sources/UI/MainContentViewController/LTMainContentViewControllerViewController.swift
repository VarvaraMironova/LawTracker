//
//  LTMainContentViewControllerViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTMainContentViewControllerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var refreshControl    : UIRefreshControl!
    var changesModel      : LTChangesModel!
    
    var byLawsArray       : [LTSectionModel] = []
    var byCommitteesArray : [LTSectionModel] = []
    var byInitiatorsArray : [LTSectionModel] = []
    
    var cellClass: AnyClass {
        get {
            return LTMainContentTableViewCell.self
        }
    }
    
    var filterType: LTFilterType {
        get {
            switch rootView.selectedButton.tag {
            case 1:
                return .byInitiators
                
            case 2:
                return .byLaws
                
            default:
                return .byCommittees
            }
        }
    }
    
    var menuViewController: LTMenuViewController {
        get {
            let menuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LTMenuViewController") as! LTMenuViewController
            menuViewController.delegate = self
            
            return menuViewController
        }
    }
    
    var helpViewController: LTHelpViewController {
        get {
            let helpViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LTHelpViewController") as! LTHelpViewController
            helpViewController.delegate = self
            
            return helpViewController
        }
    }
    
    var selectedArray: [LTSectionModel]!
    
    var rootView: LTMainContentRootView! {
        get {
            if isViewLoaded() && view.isKindOfClass(LTMainContentRootView) {
                return view as! LTMainContentRootView
            } else {
                return nil
            }
        }
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add menuViewController as a childViewController to menuContainerView
        addChildViewController(menuViewController, view: rootView.menuContainerView)
        
        //add helpViewController as a childViewController to menuContainerView
        addChildViewController(helpViewController, view: rootView.helpViewContainer)
        
        //check, if it is a first launch -> show helpViewController, create dictionary filters in SettingsModel
        let settingsModel = VTSettingModel()
        let downloadDate = NSDate().previousDay()
        
        if true != settingsModel.firstLaunch {
            //download data from server
            loadData()
        } else {
            //check date
            if downloadDate == settingsModel.lastDownloadDate {
                setChangesModel()
            } else {
                downloadChanges(downloadDate)
            }
        }
        
        rootView.fillSearchButton(downloadDate)
        
        //add refresh control
        let refreshControl = UIRefreshControl()
        rootView.contentTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "reloadTableView", forControlEvents: .ValueChanged)
        
        self.refreshControl = refreshControl
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({(UIViewControllerTransitionCoordinatorContext) -> Void in
            if self.rootView.menuShown {
                self.rootView.showMenu()
            }}, completion: {(UIViewControllerTransitionCoordinatorContext) -> Void in })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - Interface Handling
    @IBAction func onDismissFilterViewButton(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.rootView.hideMenu() {finished in}
            self.rootView.hideHelpView()
        }
    }
    
    @IBAction func onMenuButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.rootView.showMenu()
        }
    }
    
    @IBAction func onFilterButton(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            let filterController = self.storyboard!.instantiateViewControllerWithIdentifier("LTFilterViewController") as! LTFilterViewController
            filterController.delegate = self
            let filtersModel = LTFiltersModel()
            filtersModel.fetchEntities(self.filterType)
            filterController.filters = filtersModel.filters(self.filterType)
            
            self.presentViewController(filterController, animated: true, completion: nil)
        }
    }

    @IBAction func onByCommitteesButton(sender: LTSwitchButton) {
        if rootView.selectedButton != sender {
            rootView.selectedButton = sender
            selectedArray = byCommitteesArray
            
            rootView.contentTableView.reloadData()
        }
    }
    
    @IBAction func onByInitializersButton(sender: LTSwitchButton) {
        if rootView.selectedButton != sender {
            rootView.selectedButton = sender
            selectedArray = byInitiatorsArray
            
            rootView.contentTableView.reloadData()
        }
    }
    
    @IBAction func byLawsButton(sender: LTSwitchButton) {
        if rootView.selectedButton != sender {
            rootView.selectedButton = sender
            selectedArray = byLawsArray
            
            rootView.contentTableView.reloadData()
        }
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        rootView.showDatePicker()
    }
    
    @IBAction func onHidePickerButton(sender: AnyObject) {
        rootView.hideDatePicker()
    }
    
    @IBAction func onDonePickerButton(sender: AnyObject) {
        rootView.hideDatePicker()
        let date = rootView.datePicker.date
        
        downloadChanges(date)
    }
    
    func reloadTableView() {
        refreshControl.beginRefreshing()
        
        dispatch_async(dispatch_get_main_queue()) {
            let alertViewController: UIAlertController = UIAlertController(title: "Оновити базу законопроектів, ініціаторів та комітетів?", message:"Це може зайняти кілька хвилин", preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction(title: "Так", style: .Default, handler: {void in
                self.loadData()
            }))
            alertViewController.addAction(UIAlertAction(title: "Ні", style: .Default, handler: nil))
            
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
        
        refreshControl.endRefreshing()
    }
    
    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedArray[section].changes.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let model = selectedArray {
            let count = model.count
            
            return count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(cellClass, indexPath: indexPath) as! LTMainContentTableViewCell
        let model = selectedArray[indexPath.section]
        cell.fillWithModel(model.changes[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedArray[section].title
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = LTCellHeaderView.headerView() as LTCellHeaderView
        headerView.fillWithString(selectedArray[section].title)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let changes = selectedArray[indexPath.section].changes
        let changeModel = changes[indexPath.row]
        let width = CGRectGetWidth(tableView.frame) - 20.0
        let descriptionFont = UIFont(name: "Arial-BoldMT", size: 14.0)
        let lawNameHeight = changeModel.law.title.getHeight(width, font: descriptionFont!)
        let descriptionHeight = changeModel.text.getHeight(width, font: descriptionFont!)
        
        return lawNameHeight + descriptionHeight + 20.0
    }
    
    //MARK: - Private methods
    private func downloadChanges(date: NSDate) {
        rootView.fillSearchButton(date)
        rootView.noSubscriptionsLabel.hidden = true
        CoreDataStackManager.sharedInstance().clearEntity("LTChangeModel") {success, error in
            if success {
                let view = self.rootView
                view.showLoadingViewInViewWithMessage(view.contentView, message: "Завантажую новини за \(date.longString()). \nЗалишилося кілька секунд...")
                LTClient.sharedInstance().downloadChanges(date) { (success, error) -> Void in
                    view.hideLoadingView()
                    if success {
                        self.setChangesModel()
                        let settingsModel = VTSettingModel()
                        settingsModel.lastDownloadDate = date
                    } else {
                        self.processError(error!)
                    }
                }
            } else {
                self.displayError(error!)
            }
        }
    }
    
    private func setChangesModel() {
        let view = rootView
        changesModel = LTChangesModel()
        
        byCommitteesArray = changesModel.changesByKey(.byCommittees)
        byInitiatorsArray = changesModel.changesByKey(.byInitiators)
        byLawsArray = changesModel.changesByKey(.byLaws)
        
        switch filterType {
        case .byCommittees:
            selectedArray = byCommitteesArray
            
        case .byInitiators:
            selectedArray = byInitiatorsArray
            
        case .byLaws:
            selectedArray = byLawsArray
        }
        
        view.contentTableView.reloadData()
        
        view.noSubscriptionsLabel.hidden = changesModel.models.count != 0
    }
    
    private func loadData() {
        rootView.showLoadingViewInViewWithMessage(rootView.contentView, message: "Зачекайте, будь ласка. Триває завантаження законопроектів, комітетів та ініціаторів...")
        
        let client = LTClient.sharedInstance()
        
        client.downloadConvocations({ (success, error) -> Void in
            if success {
                client.downloadCommittees({ (success, error) -> Void in
                    if success {
                        client.downloadInitiatorTypes({ (success, error) -> Void in
                            if success {
                                client.downloadPersons({ (success, error) -> Void in
                                    if success {
                                        client.downloadLaws({ (success, error) -> Void in
                                            if success {
                                                let settings = VTSettingModel()
                                                if settings.firstLaunch != true {
                                                    settings.setup()
                                                }
                                                self.rootView.hideLoadingView()
                                                self.downloadChanges(NSDate().previousDay())
                                            } else {
                                                self.processError(error!)
                                            }
                                        })
                                    } else {
                                        self.processError(error!)
                                    }
                                })
                            } else {
                                self.processError(error!)
                            }
                        })
                    } else {
                        self.processError(error!)
                    }
                })
            } else {
                self.processError(error!)
            }
        })
    }
    
    private func processError(error:NSError) {
        rootView.hideLoadingView()
        rootView.noSubscriptionsLabel.hidden = false
        
        self.displayError(error)
    }
    
    func filtersDidApplied() {
        setChangesModel()
    }

}
