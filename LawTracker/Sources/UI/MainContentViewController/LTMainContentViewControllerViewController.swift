//
//  LTMainContentViewControllerViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

enum LTFilterType : Int {
    case byCommittees = 0, byInitialisers = 1, byLaws = 2
    
    static let filterTypes = [byCommittees, byInitialisers, byLaws]
}

class LTMainContentViewControllerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var arrayModel          : LTArrayModel!
    
    var byLawsArray         : [LTSectionModel] = []
    var byCommitteesArray   : [LTSectionModel] = []
    var byInitialisersArray : [LTSectionModel] = []
    
    var cellClass: AnyClass {
        get {
            return LTMainContentTableViewCell.self
        }
    }
    
    var filterType: LTFilterType {
        get {
            switch rootView.selectedButton.tag {
            case 1:
                return .byInitialisers
                
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
        
        selectedArray = byCommitteesArray
        
        //add menuViewController as a childViewController to menuContainerView
        addChildViewController(menuViewController, view: rootView.menuContainerView)
        
        //add helpViewController as a childViewController to menuContainerView
        addChildViewController(helpViewController, view: rootView.helpViewContainer)
        
        //check, if it is a first launch -> show helpViewController, create dictionary filters in SettingsModel
        let settingsModel = VTSettingModel()
        let client = LTClient.sharedInstance()
        let view = rootView
        
        if true != settingsModel.firstLaunch {
//            rootView.showHelpView()
            settingsModel.firstLaunch = true
            
            settingsModel.createFilters()
            
            //download full data from server
            view.showLoadingViewWithMessage("Зачекайте, будь ласка.\nТриває перше завантаження...")
            
            client.downloadCommittees({ (success, error) -> Void in
                if success {
                    client.downloadInitialisers({ (success, error) -> Void in
                        if success {
                            client.downloadLaws({ (success, error) -> Void in
                                if success {
                                    self.downloadChanges()
                                } else {
                                    view.noSubscriptionsLabel.hidden = false
                                    //show alert
                                }
                            })
                        } else {
                            view.noSubscriptionsLabel.hidden = false
                            //show alert
                        }
                    })
                } else {
                    view.noSubscriptionsLabel.hidden = false
                    //show alert
                }
            })
        } else {
            //check time
            //remove previous changes
            //download new changes
            downloadChanges()
        }
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
            
            switch self.filterType {
            case .byCommittees:
                filterController.filters = self.byCommitteesArray
                
                break
                
            case .byInitialisers:
                filterController.filters = self.byInitialisersArray
                
                break
                
            case .byLaws:
                filterController.filters = self.byLawsArray
                
                break
            }
            
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
            selectedArray = byInitialisersArray
            
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
    
    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedArray[section].changes.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let model = selectedArray {
            return model.count
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
        let dateFont = UIFont(name: "Arial", size: 12.0)
        let descriptionFont = UIFont(name: "Arial-BoldMT", size: 14.0)
        let lawNameHeight = changeModel.law.name.getHeight(width, font: descriptionFont!)
        let dateHeight = changeModel.date.string().getHeight(width, font: dateFont!)
        let descriptionHeight = changeModel.text.getHeight(width, font: descriptionFont!)
        
        return lawNameHeight + dateHeight + descriptionHeight + 20.0
    }
    
    //MARK: - Private methods
    private func downloadChanges() {
        let view = rootView
        view.showLoadingViewWithMessage("Зачекайте, будь ласка.\nТриває завантаження останніх змін...")
        LTClient.sharedInstance().downloadChanges({ (success, error) -> Void in
            view.hideLoadingView()
            if success {
                view.noSubscriptionsLabel.hidden = true
                self.arrayModel = LTArrayModel()
                
                self.byCommitteesArray = self.arrayModel.changesByKey(.byCommittees)
                self.byInitialisersArray = self.arrayModel.changesByKey(.byInitialisers)
                self.byLawsArray = self.arrayModel.changesByKey(.byLaws)
                
                self.selectedArray = self.byCommitteesArray
                
                view.contentTableView.reloadData()
            } else {
                view.noSubscriptionsLabel.hidden = false
                //show alert
            }
        })
    }
}
