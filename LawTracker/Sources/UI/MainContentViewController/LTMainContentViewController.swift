//
//  LTMainContentViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import CoreData
import UIKit

class LTMainContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    var loadingDate  : NSDate? {
        didSet {
            if loadingDate != oldValue {
                setArrayModel()
            }
        }
    }
    
    var arrayModel : LTChangesModel? {
        didSet {
            if let arrayModel = arrayModel as LTChangesModel! {
                //reload data
                if let rootView = rootView as LTMainContentRootView! {
                    dispatch_async(dispatch_get_main_queue()) {[weak rootView = rootView] in
                        rootView!.contentTableView.reloadData()
                    }
                }
                
                //notify observers
                var userInfo = [String: AnyObject]()
                userInfo["needLoadChangesForAnotherDay"] = 0 == arrayModel.count()
                
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName("loadChangesForAnotherDate", object: nil, userInfo: userInfo)
                }
            }
        }
    }
    
    var type : LTType? {
        didSet {
            //get model only if tabButton tapped
            if oldValue != type && oldValue != nil {
                arrayModelFromChanges()
            }
        }
    }
    
    var rootView : LTMainContentRootView? {
        get {
            if isViewLoaded() && view.isKindOfClass(LTMainContentRootView) {
                return view as? LTMainContentRootView
            } else {
                return nil
            }
        }
    }
    
    var cellClass : AnyClass {
        get {
            return LTMainContentTableViewCell.self
        }
    }
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {[unowned self] in
        let fetchRequest = NSFetchRequest(entityName: "LTChangeModel")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    //MARK: - View Life Cycle
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - gestureRecognizers
    @IBAction func onLongTapGestureRecognizer(sender: UILongPressGestureRecognizer) {
        if nil == rootView || nil == arrayModel {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView, weak arrayModel = arrayModel] in
            //find indexPath for selected row
            let tableView = rootView!.contentTableView
            let tapLocation = sender.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(tapLocation) as NSIndexPath! {
                //model for selected row
                let section = arrayModel!.changes[indexPath.section]
                let model = section.changes[indexPath.row].entity
                //complete sharing text
                let law = model.law
                var initiators = [String]()
                for initiator in law.initiators {
                    initiators.append(initiator.title!!)
                }
                
                let titles:[NSAttributedString] = [model.date.longString().attributedTitle()!, model.title.attributedTitle()!, "Законопроект #\(law.number)".attributedTitle()!, law.title.attributedText()!, "Ініціатор(и):".attributedTitle()!, initiators.joinWithSeparator(", ").attributedText()!, "Головний комітет:".attributedTitle()!, law.committee.title.attributedText()!]
                let text = titles.joinWithSeparator("\n".attributedText()!)
                let url = law.url.attributedLink()!
                
                let shareItems = [text, url]
                
                let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                if self.presentedViewController != nil {
                    return
                }
                
                self.presentViewController(activityViewController, animated: true, completion: nil)
                
                if UI_USER_INTERFACE_IDIOM() == .Pad {
                    if let popoverViewController = activityViewController.popoverPresentationController {
                        popoverViewController.permittedArrowDirections = .Any
                        popoverViewController.sourceRect = CGRectMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 4, 0, 0)
                        popoverViewController.sourceView = rootView
                    }
                }
            }
        }
    }
    
    //MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arrayModel = arrayModel as LTChangesModel! {
            return arrayModel.changes[section].changes.count
        } else {
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let rootView = rootView as LTMainContentRootView! {
            if let model = arrayModel {
                let count = model.changes.count
                rootView.noSubscriptionsLabel.hidden = count > 0
                rootView.noSubscriptionsLabel.text = "Немає данних щодо змін статусів законопроектів на цей день."
                
                return count
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(cellClass, indexPath: indexPath) as! LTMainContentTableViewCell
        
        if let arrayModel = arrayModel as LTChangesModel! {
            let model = arrayModel.changes[indexPath.section]
            dispatch_async(dispatch_get_main_queue()) {
                cell.fillWithModel(model.changes[indexPath.row])
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let arrayModel = arrayModel as LTChangesModel! {
            return arrayModel.changes[section].title
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let arrayModel = arrayModel as LTChangesModel! {
            let headerView = LTCellHeaderView.headerView() as LTCellHeaderView
            dispatch_async(dispatch_get_main_queue()) {
                headerView.fillWithString(arrayModel.changes[section].title)
            }
            
            
            return headerView
        }
        
        return nil
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let arrayModel = arrayModel as LTChangesModel! {
            let sectionModel = arrayModel.changes[indexPath.section]
            let changeModel = sectionModel.changes[indexPath.row].entity
            if let url = NSURL(string: changeModel.law.url) as NSURL! {
                let app = UIApplication.sharedApplication()
                if app.canOpenURL(url) {
                    app.openURL(url)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let arrayModel = arrayModel as LTChangesModel! {
            let changes = arrayModel.changes[indexPath.section].changes
            let changeModel = changes[indexPath.row]
            let width = CGRectGetWidth(tableView.frame) - 20.0
            let descriptionFont = UIFont(name: "Arial-BoldMT", size: 14.0)
            let lawNameHeight = changeModel.billName.getHeight(width, font: descriptionFont!)
            let descriptionHeight = changeModel.status.getHeight(width, font: descriptionFont!)
            
            return lawNameHeight + descriptionHeight + 25.0
        }
        
        return 0.0
    }
    
    //MARK: - NSNotificationCenter
    func contentDidChange(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak tableView = rootView!.contentTableView] in
            if let userInfo = notification.userInfo as [NSObject: AnyObject]! {
                if let changesModel = userInfo["changesModel"] as? LTChangesModel {
                    if changesModel.type == self.arrayModel!.type {
                        self.arrayModel = changesModel
                        if let indexPath = userInfo["indexPath"] as? NSIndexPath {
                            tableView!.beginUpdates()
                            if indexPath.row == 0 {
                                //insert new section
                                print(tableView!.numberOfSections, indexPath.section)
                                tableView!.insertSections(NSIndexSet(index: indexPath.row), withRowAnimation: .Fade)
                            }
                            
                            //insert row
                            print(tableView!.numberOfRowsInSection(indexPath.section), indexPath.row)
                            tableView!.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            
                            tableView!.endUpdates()
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Public
    func arrayModelFromChanges() {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak loadingDate = loadingDate] in
            if let loadingDate = loadingDate as NSDate! {
                if let type = self.type as LTType! {
                    let changesList = self.sectionModelsByKey(type)
                    let arrayModel = LTChangesModel(changes: changesList, type: type, filtersApplied: false, date: loadingDate)
                    
                    self.applyFilters(arrayModel, completionHandler: { (result, finish) -> Void in
                        self.arrayModel = result
                    })
                }
            }
        }
    }
    
    func applyFilters(arrayModel: LTChangesModel, completionHandler:(arrayModel: LTChangesModel, finish: Bool) -> Void) {
        dispatch_async(CoreDataStackManager.coreDataQueue()) {
            if let filters = LTEntityModel.filteredEntities(arrayModel.type) as [LTEntityModel]! {
                if filters.count > 0 {
                    var filteredSections = [LTSectionModel]()
                    for sectionModel in arrayModel.changes {
                        for entity in sectionModel.entities {
                            if filters.contains(entity) {
                                filteredSections.append(sectionModel)
                            }
                        }
                    }
                    
                    completionHandler(arrayModel: LTChangesModel(changes: filteredSections, type: arrayModel.type, filtersApplied: true, date: arrayModel.date), finish: true)
                    
                    return
                }
            }
            
            completionHandler(arrayModel: arrayModel, finish: true)
        }
    }
    
    func applyFiltersForSection(sectionModel: LTSectionModel, completionHandler:(result: LTSectionModel?, finish: Bool) -> Void) {
        dispatch_async(CoreDataStackManager.coreDataQueue()) {[unowned self] in
            if let type = self.type as LTType! {
                if let filters = LTEntityModel.filteredEntities(type) as [LTEntityModel]! {
                    if filters.count > 0 {
                        var result = LTSectionModel()
                        for entity in sectionModel.entities {
                            if filters.contains(entity) {
                                result = sectionModel
                                break
                            }
                        }
                        
                        completionHandler(result: result, finish: true)
                        return
                    }
                    
                    completionHandler(result: nil, finish: true)
                }
            } else {
                completionHandler(result: sectionModel, finish: true)
            }
        }
    }
    
    //MARK: - Private
    private func sectionModelsByKey(key: LTType) -> [LTSectionModel]! {
        var result = [LTSectionModel]()
        if let changes = fetchedResultsController.fetchedObjects as? [LTChangeModel] {
            for changeModel in changes {
                createSectionByKey(changeModel, key: key) { (newsModel, sectionModel, finish) in
                    if let newsModel = newsModel as LTNewsModel! {
                        if let sectionModel = sectionModel as LTSectionModel! {
                            let existedSectionModel = result.filter() { $0.entities == sectionModel.entities }.first
                            if nil == existedSectionModel {
                                result.append(sectionModel)
                            } else {
                                existedSectionModel!.addModel(newsModel)
                            }
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    private func createSectionByKey(changeModel: LTChangeModel, key: LTType, completionHandler:(newsModel: LTNewsModel?, sectionModel: LTSectionModel?, finish: Bool) -> Void) {
        let bill = changeModel.law
        if bill.title == "" {
            completionHandler(newsModel: nil, sectionModel: nil, finish: true)
            return
        }
        
        let newsModel = LTNewsModel(entity: changeModel, type: key)
        switch key {
        case .byLaws:
            let bills = [bill]
            let sectionBillModel = LTSectionModel(entities: bills)
            sectionBillModel.addModel(newsModel)
            completionHandler(newsModel: newsModel, sectionModel: sectionBillModel, finish: true)
            
            break
            
        case .byInitiators:
            var initiators = [LTInitiatorModel]()
            if let initiatorsArray = bill.initiators.allObjects as? [LTInitiatorModel] {
                initiators = initiatorsArray
            }
            
            let sectionInitiatorModel = LTSectionModel(entities: initiators)
            sectionInitiatorModel.addModel(newsModel)
            completionHandler(newsModel: newsModel, sectionModel: sectionInitiatorModel, finish: true)
            
            break
            
        case .byCommittees:
            let committees = [bill.committee]
            let sectionCommitteeModel = LTSectionModel(entities: committees)
            sectionCommitteeModel.addModel(newsModel)
            completionHandler(newsModel: newsModel, sectionModel: sectionCommitteeModel, finish: true)
            
            break
        }
    }
    
    private func setArrayModel() {
        fetchChanges {[unowned self] (finish) -> Void in
            if finish {
                self.arrayModelFromChanges()
            }
        }
    }
    
    private func fetchChanges(completionHandler:(finish: Bool) -> Void) {
        dispatch_async(CoreDataStackManager.coreDataQueue()) {[unowned self, weak fetchedResultsController = fetchedResultsController, weak loadingDate = loadingDate] in
            if let loadingDate = loadingDate as NSDate! {
                fetchedResultsController!.fetchRequest.predicate = NSPredicate(format: "date = %@", loadingDate.dateWithoutTime())
                do {
                    try fetchedResultsController!.performFetch()
                } catch {}
                
                fetchedResultsController!.delegate = self
                
                completionHandler(finish: true)
            }
        }
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if nil == rootView {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {[weak tableView = rootView!.contentTableView] in
            tableView!.beginUpdates()
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if nil == self.type {
            return
        }
        //create section and newsModel from changeModel
        if let changeModel = anObject as? LTChangeModel {
            createSectionByKey(changeModel, key: self.type!, completionHandler: {[weak arrayModel = arrayModel, weak rootView = rootView] (newsModel, sectionModel, finish) -> Void in
                if let newsModel = newsModel as LTNewsModel! {
                    if let sectionModel = sectionModel as LTSectionModel! {
                        //apply filters for section model if needed
                        if (arrayModel!.filtersApplied && sectionModel.filtersSet) || !arrayModel!.filtersApplied {
                            let existedSectionModel = arrayModel!.sectionWithEntities(sectionModel.entities)
                            var row = 0
                            var section = 0
                            
                            if nil == existedSectionModel {
                                //add new sectionModel to arrayModel
                                arrayModel!.addModel(sectionModel)
                                section = arrayModel!.count() - 1
                                
                                //insert row and section to tableView
                                dispatch_async(dispatch_get_main_queue()) {
                                    if arrayModel!.count() == section + 1 {
                                        rootView!.contentTableView.insertSections(NSIndexSet(index: section), withRowAnimation: .Fade)
                                        rootView!.contentTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: section)], withRowAnimation: .Fade)
                                    }
                                }
                            } else {
                                //add newsModel to existedSectionModel
                                if nil == existedSectionModel!.newsModelWithEntity(newsModel.entity) {
                                    existedSectionModel!.addModel(newsModel)
                                    row = existedSectionModel!.count() - 1
                                    section = arrayModel!.changes.indexOf(existedSectionModel!)!
                                    
                                    //insert row to tableView
                                    dispatch_async(dispatch_get_main_queue()) {
                                        let indexPath = NSIndexPath(forRow: row, inSection: section)
                                        if arrayModel!.changes[section].count() == row + 1 {
                                            rootView!.contentTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if nil == rootView {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {[weak tableView = rootView!.contentTableView] in
            tableView!.endUpdates()
        }
    }
    
}
