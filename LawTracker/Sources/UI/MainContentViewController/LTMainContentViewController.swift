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
    var loadingDate  : Date? {
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
                    DispatchQueue.main.async {[weak rootView = rootView] in
                        rootView!.contentTableView.reloadData()
                    }
                }
                
                //notify observers
                var userInfo = [String: AnyObject]()
                userInfo["needLoadChangesForAnotherDay"] = (0 == arrayModel.count()) as AnyObject
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loadChangesForAnotherDate"), object: nil, userInfo: userInfo)
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
            if isViewLoaded && view.isKind(of: LTMainContentRootView.self) {
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
    lazy var fetchedResultsController = { () -> NSFetchedResultsController<LTChangeModel> in
        let fetchRequest = NSFetchRequest<LTChangeModel>(entityName: "LTChangeModel")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    //MARK: - View Life Cycle
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //MARK: - gestureRecognizers
    @IBAction func onLongTapGestureRecognizer(_ sender: UILongPressGestureRecognizer) {
        if nil == rootView || nil == arrayModel {
            return
        }
        
        DispatchQueue.main.async {[unowned self, weak rootView = rootView, weak arrayModel = arrayModel] in
            //find indexPath for selected row
            let tableView = rootView!.contentTableView
            let tapLocation = sender.location(in: tableView)
            if let indexPath = tableView?.indexPathForRow(at: tapLocation) as IndexPath! {
                //model for selected row
                let section = arrayModel!.changes[indexPath.section]
                let model = section.changes[indexPath.row].entity
                //complete sharing text
                let law = model?.law
                var initiators = [String]()
                for initiator in (law?.initiators)! {
                    initiators.append((initiator as AnyObject).title!!)
                }
                
                let titles:[NSAttributedString] = [model!.date.longString().attributedTitle()!, model!.title.attributedTitle()!, "Законопроект #\(law!.number)".attributedTitle()!, law!.title.attributedText()!, "Ініціатор(и):".attributedTitle()!, initiators.joined(separator: ", ").attributedText()!, "Головний комітет:".attributedTitle()!, law!.committee.title.attributedText()!]
                let text = titles.joinWithSeparator("\n".attributedText()!)
                let url = law!.url.attributedLink()!
                
                let shareItems = [text, url]
                
                let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                if self.presentedViewController != nil {
                    return
                }
                
                self.present(activityViewController, animated: true, completion: nil)
                
                if UI_USER_INTERFACE_IDIOM() == .pad {
                    if let popoverViewController = activityViewController.popoverPresentationController {
                        popoverViewController.permittedArrowDirections = .any
                        popoverViewController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 4, width: 0, height: 0)
                        popoverViewController.sourceView = rootView
                    }
                }
            }
        }
    }
    
    //MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arrayModel = arrayModel as LTChangesModel! {
            return arrayModel.changes[section].changes.count
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let rootView = rootView as LTMainContentRootView! {
            if let model = arrayModel {
                let count = model.changes.count
                rootView.noSubscriptionsLabel.isHidden = count > 0
                rootView.noSubscriptionsLabel.text = "Немає данних щодо змін статусів законопроектів на цей день."
                
                return count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(cellClass, indexPath: indexPath) as! LTMainContentTableViewCell
        
        if let arrayModel = arrayModel as LTChangesModel! {
            if arrayModel.changes.count > indexPath.section {
                let model = arrayModel.changes[indexPath.section]
                DispatchQueue.main.async {
                    if model.changes.count > indexPath.row {
                        cell.fillWithModel(model.changes[indexPath.row])
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let arrayModel = arrayModel as LTChangesModel! {
            if arrayModel.changes.count > section {
                return arrayModel.changes[section].title
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let arrayModel = arrayModel as LTChangesModel! {
            let headerView = LTCellHeaderView.headerView() as LTCellHeaderView
            DispatchQueue.main.async {
                if arrayModel.changes.count > section {
                    headerView.fillWithString(arrayModel.changes[section].title)
                }
            }
            
            
            return headerView
        }
        
        return nil
    }
    
    //MARK: - UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let arrayModel = arrayModel as LTChangesModel! {
            if arrayModel.changes.count > indexPath.section {
                let sectionModel = arrayModel.changes[indexPath.section]
                if sectionModel.changes.count > indexPath.row {
                    let changeModel = sectionModel.changes[indexPath.row].entity
                    if let url = URL(string: (changeModel?.law.url)!) as URL! {
                        let app = UIApplication.shared
                        if app.canOpenURL(url) {
                            app.openURL(url)
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let arrayModel = arrayModel as LTChangesModel! {
            if arrayModel.changes.count > indexPath.section {
                let changes = arrayModel.changes[indexPath.section].changes
                if changes.count > indexPath.row {
                    let changeModel = changes[indexPath.row]
                    let width = tableView.frame.width - 20.0
                    let descriptionFont = UIFont(name: "Arial-BoldMT", size: 14.0)
                    let lawNameHeight = changeModel.billName.getHeight(width, font: descriptionFont!)
                    let descriptionHeight = changeModel.status.getHeight(width, font: descriptionFont!)
                    
                    return lawNameHeight + descriptionHeight + 25.0
                }
            }
        }
        
        return 0.0
    }
    
    //MARK: - Public
    func arrayModelFromChanges() {
        DispatchQueue.main.async {[unowned self, loadingDate = loadingDate] in
            if let loadingDate = loadingDate as Date! {
                if let type = self.type as LTType! {
                    let changesList = self.sectionModelsByKey(type)
                    let arrayModel = LTChangesModel(changes: changesList!, type: type, filtersApplied: false, date: loadingDate)
                    
                    self.applyFilters(arrayModel, completionHandler: { (result, finish) -> Void in
                        self.arrayModel = result
                    })
                }
            }
        }
    }
    
    func applyFilters(_ arrayModel: LTChangesModel, completionHandler:@escaping (_ arrayModel: LTChangesModel, _ finish: Bool) -> Void) {
        CoreDataStackManager.coreDataQueue().async {
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
                    
                    completionHandler(LTChangesModel(changes: filteredSections, type: arrayModel.type, filtersApplied: true, date: arrayModel.date), true)
                    
                    return
                }
            }
            
            completionHandler(arrayModel, true)
        }
    }
    
    func applyFiltersForSection(_ sectionModel: LTSectionModel, completionHandler:@escaping (_ result: LTSectionModel?, _ finish: Bool) -> Void) {
        CoreDataStackManager.coreDataQueue().async {[unowned self] in
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
                        
                        completionHandler(result, true)
                        return
                    }
                    
                    completionHandler(nil, true)
                }
            } else {
                completionHandler(sectionModel, true)
            }
        }
    }
    
    //MARK: - Private
    fileprivate func sectionModelsByKey(_ key: LTType) -> [LTSectionModel]! {
        var result = [LTSectionModel]()
        if let changes = fetchedResultsController.fetchedObjects {
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
    
    fileprivate func createSectionByKey(_ changeModel: LTChangeModel, key: LTType, completionHandler:(_ newsModel: LTNewsModel?, _ sectionModel: LTSectionModel?, _ finish: Bool) -> Void) {
        let bill = changeModel.law
        if bill.title == "" {
            completionHandler(nil, nil, true)
            return
        }
        
        let newsModel = LTNewsModel(entity: changeModel, type: key)
        switch key {
        case .byLaws:
            let bills = [bill]
            let sectionBillModel = LTSectionModel(entities: bills)
            sectionBillModel.addModel(newsModel)
            completionHandler(newsModel, sectionBillModel, true)
            
            break
            
        case .byInitiators:
            var initiators = [LTInitiatorModel]()
            if let initiatorsArray = bill.initiators.allObjects as? [LTInitiatorModel] {
                initiators = initiatorsArray
            }
            
            let sectionInitiatorModel = LTSectionModel(entities: initiators)
            sectionInitiatorModel.addModel(newsModel)
            completionHandler(newsModel, sectionInitiatorModel, true)
            
            break
            
        case .byCommittees:
            let committees = [bill.committee]
            let sectionCommitteeModel = LTSectionModel(entities: committees)
            sectionCommitteeModel.addModel(newsModel)
            completionHandler(newsModel, sectionCommitteeModel, true)
            
            break
        }
    }
    
    fileprivate func setArrayModel() {
        fetchChanges {[unowned self] (finish) -> Void in
            if finish {
                self.arrayModelFromChanges()
            }
        }
    }
    
    fileprivate func fetchChanges(_ completionHandler:@escaping (_ finish: Bool) -> Void) {
        CoreDataStackManager.coreDataQueue().async {[unowned self, weak fetchedResultsController = fetchedResultsController, loadingDate = loadingDate] in
            if let loadingDate = loadingDate as Date! {
                fetchedResultsController!.fetchRequest.predicate = NSPredicate(format: "date = %@", (loadingDate.dateWithoutTime() as NSDate))
                do {
                    try fetchedResultsController!.performFetch()
                } catch {}
                
                fetchedResultsController!.delegate = self
                
                completionHandler(true)
            }
        }
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if nil == self.type {
            return
        }
        //create section and newsModel from changeModel
        if let changeModel = anObject as? LTChangeModel {
            createSectionByKey(changeModel, key: self.type!, completionHandler: {[weak arrayModel = arrayModel, weak tableView = rootView!.contentTableView] (newsModel, sectionModel, finish) -> Void in
                if let newsModel = newsModel as LTNewsModel! {
                    if let sectionModel = sectionModel as LTSectionModel! {
                        //apply filters for section model if needed
                        if (arrayModel!.filtersApplied && sectionModel.filtersSet) || !arrayModel!.filtersApplied {
                            DispatchQueue.main.async {
                                let existedSectionModel = arrayModel!.sectionWithEntities(sectionModel.entities)
                                var row = 0
                                var section = 0
                                tableView!.beginUpdates()
                                if nil == existedSectionModel {
                                    //add new sectionModel to arrayModel
                                    arrayModel!.addModel(sectionModel)
                                    section = arrayModel!.count() - 1
                                    
                                    //insert row and section to tableView
                                    if arrayModel!.count() == section + 1 {
                                        tableView!.insertSections(IndexSet(integer: section), with: .fade)
                                        tableView!.insertRows(at: [IndexPath(row: row, section: section)], with: .fade)
                                    }
                                } else {
                                    //add newsModel to existedSectionModel
                                    if nil == existedSectionModel!.newsModelWithEntity(newsModel.entity) {
                                        existedSectionModel!.addModel(newsModel)
                                        row = existedSectionModel!.count() - 1
                                        section = arrayModel!.changes.index(of: existedSectionModel!)!
                                        
                                        //insert row to tableView
                                        let indexPath = IndexPath(row: row, section: section)
                                        if arrayModel!.changes[section].count() == row + 1 {
                                            tableView!.insertRows(at: [indexPath], with: .fade)
                                        }
                                    }
                                }
                                
                                tableView!.endUpdates()
                            }
                        }
                    }
                }
            })
        }
    }
    
}
