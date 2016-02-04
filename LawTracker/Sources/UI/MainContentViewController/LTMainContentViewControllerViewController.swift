//
//  LTMainContentViewControllerViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

let kLTMaxLoadingCount = 30

class LTMainContentViewControllerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var refreshControl    : UIRefreshControl!
    var changesModel      : LTArrayModel!
    
    var byLawsArray       : LTChangesModel! {
        didSet {
            rootView.byLawsButton.filtersSet = byLawsArray.filtersIsApplied
        }
    }
    
    var byCommitteesArray : LTChangesModel! {
        didSet {
            rootView.byCommitteesButton.filtersSet = byCommitteesArray.filtersIsApplied
        }
    }
    
    var byInitiatorsArray : LTChangesModel! {
        didSet {
            rootView.byInitialisersButton.filtersSet = byInitiatorsArray.filtersIsApplied
        }
    }
    
    var cellClass: AnyClass {
        get {
            return LTMainContentTableViewCell.self
        }
    }
    
    var filterType: LTType {
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
    
    var selectedArray: LTChangesModel!
    
    var rootView     : LTMainContentRootView! {
        get {
            if isViewLoaded() && view.isKindOfClass(LTMainContentRootView) {
                return view as! LTMainContentRootView
            } else {
                return nil
            }
        }
    }
    
    var loadedAtFirst : Bool = true
    var loadingCount  : Int = 0
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add menuViewController as a childViewController to menuContainerView
        addChildViewController(menuViewController, view: rootView.menuContainerView)
        
        //add helpViewController as a childViewController to menuContainerView
        addChildViewController(helpViewController, view: rootView.helpViewContainer)
        
        //check, if it is a first launch -> show helpViewController, create dictionary filters in SettingsModel
        let settingsModel = VTSettingModel()
        if settingsModel.firstLaunch != true {
            rootView.showHelpView()
        }
        
        if true != settingsModel.firstLaunch {
            //download data from server
            loadData()
        } else {
            downloadChanges(NSDate().previousDay())
        }
        
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
            let view = self.rootView
            view.hideMenu() {finished in}
            view.hideHelpView()
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
            
            var entityName = String()
            switch self.filterType {
            case .byCommittees:
                entityName = "LTCommitteeModel"
                break
                
            case .byInitiators:
                entityName = "LTInitiatorModel"
                break
                
            case .byLaws:
                entityName = "LTLawModel"
                break
            }
            
            let filters = LTArrayModel(entityName: entityName, predicate: NSPredicate(value: true))
            filterController.filters = filters.filters(self.filterType)
            
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
    
    //MARK: - gestureRecognizers
    @IBAction func onLongTapGestureRecognizer(sender: UILongPressGestureRecognizer) {
        //find indexPath for selected row
        let tableView = rootView.contentTableView
        let tapLocation = sender.locationInView(tableView)
        if let indexPath = tableView.indexPathForRowAtPoint(tapLocation) as NSIndexPath! {
            //model for selected rpw
            let section = selectedArray.changes[indexPath.section]
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
        return selectedArray.changes[section].changes.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let model = selectedArray {
            let count = model.changes.count
            
            return count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(cellClass, indexPath: indexPath) as! LTMainContentTableViewCell
        
        let model = selectedArray.changes[indexPath.section]
        cell.fillWithModel(model.changes[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedArray.changes[section].title
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = LTCellHeaderView.headerView() as LTCellHeaderView
        headerView.fillWithString(selectedArray.changes[section].title)
        
        return headerView
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sectionModel = selectedArray.changes[indexPath.section]
        let changeModel = sectionModel.changes[indexPath.row]
        if let url = NSURL(string: changeModel.law.url) as NSURL! {
            let app = UIApplication.sharedApplication()
            if app.canOpenURL(url) {
                app.openURL(url)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let changes = selectedArray.changes[indexPath.section].changes
        let changeModel = changes[indexPath.row]
        let width = CGRectGetWidth(tableView.frame) - 20.0
        let descriptionFont = UIFont(name: "Arial-BoldMT", size: 14.0)
        let lawNameHeight = changeModel.law.title.getHeight(width, font: descriptionFont!)
        let descriptionHeight = changeModel.title.getHeight(width, font: descriptionFont!)
        
        return lawNameHeight + descriptionHeight + 20.0
    }
    
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let offset = scrollView.contentOffset;
//        let bounds = scrollView.frame;
//        let size = scrollView.contentSize;
//        let inset = scrollView.contentInset;
//        let y = offset.y + bounds.size.height - inset.bottom;
//        let h = size.height;
//        
//        let reload_distance : CGFloat = 10.0;
//        if y > h + reload_distance {
//            //download status changes for previous day
//            let currentDate = rootView.datePicker.date
//            downloadChanges(currentDate.previousDay())
//        }
//    }
    
    //MARK: - Private methods
    private func downloadChanges(date: NSDate) {
        let view = self.rootView
        
        view.fillSearchButton(date)
        view.noSubscriptionsLabel.hidden = true
        
        if let _ = LTChangeModel.changesForDate(date) as [LTChangeModel]! {
            setChangesModel(date)
            
            return
        }
        
        view.showLoadingViewInViewWithMessage(view.contentView, message: "Завантажую новини за \(date.longString()) \nЗалишилося кілька секунд...")
        LTClient.sharedInstance().downloadChanges(date) { (success, error) -> Void in
            view.hideLoadingView()
            if success {
                self.setChangesModel(date)
                let settingsModel = VTSettingModel()
                settingsModel.lastDownloadDate = date
            } else {
                self.processError(error!)
            }
        }
    }
    
    private func setChangesModel(date: NSDate) {
        let view = rootView
        changesModel = LTArrayModel(entityName: "LTChangeModel", predicate: NSPredicate(format: "date = %@", date))
        
        if (loadedAtFirst) && (changesModel.count() == 0) && (loadingCount < kLTMaxLoadingCount) {
            loadingCount += 1
            downloadChanges(date.previousDay())
            
            return
        }
        
        loadedAtFirst = false
        
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
        rootView.showLoadingViewInViewWithMessage(rootView.contentView, message: "Зачекайте, будь ласка.\nТриває завантаження законопроектів, комітетів та ініціаторів...")
        
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
    
    //MARK: - LTFilterDelegate methods
    func filtersDidApplied() {
        setChangesModel(rootView.datePicker.date)
    }

}
