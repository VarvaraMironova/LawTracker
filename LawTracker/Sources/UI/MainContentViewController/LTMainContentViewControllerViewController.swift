//
//  LTMainContentViewControllerViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

let Commitee1 = "Комітет з питань аграрної політики та земельних відносин"
let Commitee2 = "Комітет з питань будівництва, містобудування і житлово-комунального господарства"
let Commitee3 = "Комітет з питань бюджету"
let Commitee4 = "Комітет з питань державного будівництва, регіональної політики та місцевого самоврядування"
let Commitee5 = "Комітет з питань екологічної політики, природокористування та ліквідації наслідків Чорнобильської катастрофи"

let init1 = "Президент"
let init2 = "Національний Банк України"
let init3 = "Кабінет містрів України"
let init4 = "Депутати"

let law1 = "Проект Закону про внесення змін до статті 1071 Цивільного кодексу України (щодо списання коштів з рахунка померлого потерпілого від нещасного випадку на виробництві)"
let law2 = "Проект Закону про внесення змін до деяких законів України щодо посилення гарантій безпеки дітей"
let law3 = "Проект Закону про внесення змін до Закону України \"Про підприємництво\""
let law4 = "Проект Закону про внесення змін до деяких законодавчих актів України щодо земельних ділянок багатоквартирних будинків"
let law5 = "Проект Постанови про відхилення проекту Закону України про внесення змін до Закону України \"Про основні принципи та вимоги до безпечності та якості харчових продуктів\" щодо приведення норм до вимог Митного кодексу"
let law6 = "Проект Закону про ратифікацію Угоди між Україною та Королівством Іспанія про взаємну охорону інформації з обмеженим доступом"

//news
let date1 = "03 грудня 2015, 17:09"
let desc1 = "Направлений до комітетів та розміщений на Веб-сайті Верховної Ради України"
let date2 = "03 грудня 2015, 17:07"
let desc2 = "Прийнятий на поточній сесії"
let date3 = "03 грудня 2015, 17:04"
let desc3 = "Зареєстрований"

class LTMainContentViewControllerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var loaded : Bool = false
    
    lazy var commiteesArray: [LTSectionModel] = {
        [unowned self] in
        return [LTSectionModel(title:Commitee1, changes:self.arrayModel), LTSectionModel(title:Commitee2, changes:self.arrayModel), LTSectionModel(title:Commitee3, changes:self.arrayModel), LTSectionModel(title:Commitee4, changes:self.arrayModel), LTSectionModel(title:Commitee5, changes:self.arrayModel)]
        }()
    
    lazy var initializatorsArray: [LTSectionModel] = {
        [unowned self] in
        return [LTSectionModel(title:init1, changes:self.arrayModel), LTSectionModel(title:init2, changes:self.arrayModel), LTSectionModel(title:init3, changes:self.arrayModel), LTSectionModel(title:init4, changes:self.arrayModel)]
        }()
    
    lazy var lawsArray: [LTSectionModel] = {
        [unowned self] in
        return [LTSectionModel(title:law1, changes:self.arrayModel), LTSectionModel(title:law2, changes:self.arrayModel), LTSectionModel(title:law3, changes:self.arrayModel), LTSectionModel(title:law4, changes:self.arrayModel), LTSectionModel(title:law5, changes:self.arrayModel), LTSectionModel(title:law6, changes:self.arrayModel)]
        }()
    
    lazy var arrayModel: [LTChangeModel] = {
        [unowned self] in
        return [LTChangeModel(date:date1, description:desc1), LTChangeModel(date:date2, description:desc2), LTChangeModel(date:date3, description:desc3)]
        }()
    
    var menuViewController: LTMenuViewController {
        get {
            let menuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LTMenuViewController") as! LTMenuViewController
            menuViewController.delegate = self
            
            return menuViewController
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedArray = commiteesArray
        
        //add menuViewController as a childViewController to menuContainerView
        addChildViewController(menuViewController, view: rootView.menuContainerView)
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
    
    @IBAction func onDismissFilterViewButton(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            dispatch_async(dispatch_get_main_queue()) {
                self.rootView.showMenu()
            }
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
            filterController.filteredArray = []
            switch self.rootView.filterType {
            case .byCommettees:
                filterController.searchArray = self.commiteesArray
                filterController.placeholderString = "Зазначте комітет"
                break
                
            case .byInitializers:
                filterController.searchArray = self.initializatorsArray
                filterController.placeholderString = "Зазначте ініціатора"
                break
                
            case .byLaws:
                filterController.searchArray = self.lawsArray
                filterController.placeholderString = "Зазначте назву закону"
                break
            }
            
            self.presentViewController(filterController, animated: true, completion: nil)
        }
    }

    @IBAction func onByCommetteesButton(sender: LTSwitchButton) {
        rootView.selectedButton = sender
        selectedArray = commiteesArray
        
        rootView.contentTableView.reloadData()
    }
    
    @IBAction func onByInitializersButton(sender: LTSwitchButton) {
        rootView.selectedButton = sender
        selectedArray = initializatorsArray
        
        rootView.contentTableView.reloadData()
    }
    
    @IBAction func byLawsButton(sender: LTSwitchButton) {
        rootView.selectedButton = sender
        selectedArray = lawsArray
        
        rootView.contentTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedArray[section].changes.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let count = selectedArray.count
        rootView.noSubscriptionsLabel.hidden = count > 0
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTMainContentTableViewCell", forIndexPath: indexPath) as! LTMainContentTableViewCell
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
        let news = selectedArray[indexPath.section].changes
        let newsModel = news[indexPath.row]
        let width = CGRectGetWidth(tableView.frame) - 20.0
        let dateFont = UIFont(name: "Arial", size: 12.0)
        let descriptionFont = UIFont(name: "Arial", size: 14.0)
        let dateHeight = newsModel.date.getHeight(width, font: dateFont!)
        let descriptionHeight = newsModel.description.getHeight(width, font: descriptionFont!)
        
        return dateHeight + descriptionHeight + 20.0
    }
    
}
