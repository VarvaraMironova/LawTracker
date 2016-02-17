//
//  LTArrayModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/26/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData
import Foundation

class LTArrayModel: NSObject, NSFetchedResultsControllerDelegate {
    var entityName  : String!
    var predicate   : NSPredicate!
    var downloadDate: NSDate!
    
    var chagesByBill      : LTChangesModel!
    var chagesByCommittee : LTChangesModel!
    var chagesByInitiator : LTChangesModel!
    
    private var observerContext = 0
    
    var models: [LTEntityModel]! = [LTEntityModel]() {
        didSet {
            if oldValue != models {
                if let changes = models as? [LTChangeModel] {
                    for changeModel in changes {
                        changeModel.addObserver(self, forKeyPath: "law", options: .New, context: &observerContext)
                    }
                }
            }
        }
    }
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: self.entityName)
        fetchRequest.predicate = self.predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    deinit {
        if let changes = models as? [LTChangeModel] {
            for changeModel in changes {
                changeModel.removeObserver(self, forKeyPath: "law")
            }
        }
    }
    
    init(entityName: String, predicate: NSPredicate, date: NSDate) {
        super.init()
        
        self.predicate = predicate
        self.entityName = entityName
        self.downloadDate = date
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    //MARK: - Public
    func filters(key: LTType) -> [LTSectionModel] {
        models = fetchedResultsController.fetchedObjects as? [LTEntityModel]
        if nil == models {
            return [LTSectionModel]()
        }
        
        var filters = [LTSectionModel]()
        
        switch key {
        case .byCommittees:
            filters.append(LTSectionModel())
            
            break
            
        case .byInitiators:
            filters.append(LTSectionModel())
            let sectionModel = LTSectionModel()
            sectionModel.title = "Народні депутати України"
            filters.append(sectionModel)
            
            break
            
        case .byLaws:
            filters.append(LTSectionModel())
            
            break
        }
        
        for model in models! {
            let filterModel = LTFilterCellModel(entity: model)
            
            switch key {
            case .byInitiators:
                if let initiator = model as? LTInitiatorModel {
                    let title = initiator.isDeputy ? "Народні депутати України" : ""
                    let sectionModel = filters.filter(){ $0.title == title }.first
                    if let section = sectionModel as LTSectionModel! {
                        section.filters.append(filterModel)
                    }
                }
                
                break
                
            default:
                if let sectionModel = filters.first as LTSectionModel! {
                    sectionModel.filters.append(filterModel)
                }
                
                break
            }
        }
        
        return filters
    }
    
    func changes(completionHandler:(bills: LTChangesModel, initiators: LTChangesModel, committees: LTChangesModel, finish: Bool) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        let date = downloadDate
        models = fetchedResultsController.fetchedObjects as? [LTEntityModel]
        if nil == models {
            return
        }
        
        dispatch_async(queue) {
            let billsList = self.sectionModelsByKey(.byLaws)
            let committeesList = self.sectionModelsByKey(.byCommittees)
            let initiatorsList = self.sectionModelsByKey(.byInitiators)
            
            let byBillsChanges = self.applyFilters(billsList, key: .byLaws)
            let billsFilterApplied = nil != byBillsChanges
            let byInitiatorsChanges = self.applyFilters(initiatorsList, key: .byInitiators)
            let initiatorsFilterApplied = nil != byInitiatorsChanges
            let byCommitteesChanges = self.applyFilters(committeesList, key: .byCommittees)
            let committeesFilterApplied = nil != byCommitteesChanges
            
            let chagesByBill = LTChangesModel(changes: nil == byBillsChanges ? billsList : byBillsChanges, filtersApplied: billsFilterApplied, date: date)
            let chagesByCommittee = LTChangesModel(changes: nil == byCommitteesChanges ? committeesList : byCommitteesChanges, filtersApplied: committeesFilterApplied, date: date)
            let chagesByInitiator = LTChangesModel(changes: nil == byInitiatorsChanges ? initiatorsList : byInitiatorsChanges, filtersApplied: initiatorsFilterApplied, date: date)
            
            completionHandler(bills: chagesByBill, initiators: chagesByInitiator, committees: chagesByCommittee, finish: true)
            
            self.chagesByBill = chagesByBill
            self.chagesByCommittee = chagesByCommittee
            self.chagesByInitiator = chagesByInitiator
        }
    }
    
    func count() -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    //MARK: - Private
    private func sectionModelsByKey(key: LTType) -> [LTSectionModel]! {
        var result = [LTSectionModel]()
        let changes = models!.map(
            {(element: LTEntityModel) -> LTChangeModel in
                return element as! LTChangeModel
        })
        
        for changeModel in changes {
            let bill = changeModel.law
            if bill.title != "" {
                let newsModel = LTNewsModel(entity: changeModel, type: key)
                
                switch key {
                case .byLaws:
                    let bills = [bill]
                    
                    var sectionBillModel = result.filter(){ $0.entities == bills }.first
                    if nil == sectionBillModel {
                        sectionBillModel = LTSectionModel(entities: bills)
                        sectionBillModel!.changes.append(newsModel)
                        result.append(sectionBillModel!)
                    } else {
                        sectionBillModel!.changes.append(newsModel)
                    }
                    
                    break
                    
                case .byInitiators:
                    var initiators = [LTEntityModel]()
                    if let initiatorsArray = bill.initiators.allObjects as? [LTInitiatorModel] {
                        initiators = initiatorsArray
                    }
                    
                    var sectionInitiatorModel = result.filter(){ $0.entities == initiators }.first
                    if nil == sectionInitiatorModel {
                        sectionInitiatorModel = LTSectionModel(entities: initiators)
                        sectionInitiatorModel!.changes.append(newsModel)
                        result.append(sectionInitiatorModel!)
                    } else {
                        sectionInitiatorModel!.changes.append(newsModel)
                    }
                    
                    break
                    
                case .byCommittees:
                    let committees = [bill.committee]
                    var sectionCommitteeModel = result.filter(){ $0.entities == committees }.first
                    if nil == sectionCommitteeModel {
                        sectionCommitteeModel = LTSectionModel(entities: committees)
                        sectionCommitteeModel!.changes.append(newsModel)
                        result.append(sectionCommitteeModel!)
                    } else {
                        sectionCommitteeModel!.changes.append(newsModel)
                    }
                    
                    break
                }
            }
        }
        
        return result
    }
    
    private func applyFilters(array: [LTSectionModel], key: LTType) -> [LTSectionModel]? {
        if let initiatorsFilters = LTEntityModel.filteredEntities(key) as [LTEntityModel]! {
            if initiatorsFilters.count > 0 {
                var filteredArray = [LTSectionModel]()
                for sectionModel in array {
                    for entity in sectionModel.entities {
                        if initiatorsFilters.contains(entity) {
                            filteredArray.append(sectionModel)
                        }
                    }
                }
                
                return filteredArray
            }
        }
        
        return nil
    }
    
    private func processNotification(model: LTChangesModel, changeModel: LTChangeModel, bill: LTLawModel, entities: [LTEntityModel], type: LTType) {
        let newsModel = LTNewsModel(entity: changeModel, type: type)
        if chagesByBill.filtersApplied == true {
            if bill.filterSet {
                completeChangesModel(model, entities: entities, newsModel: newsModel)
            }
        } else {
            completeChangesModel(model, entities: entities, newsModel: newsModel)
        }
    }
    
    private func completeChangesModel(model: LTChangesModel, entities: [LTEntityModel], newsModel: LTNewsModel) {
        //check if model contains object
        if let sectionModel = model.sectionWithEntities(entities) as LTSectionModel! {
            let sectionIndex = model.changes.indexOf(sectionModel)
            //add NewsModel to sectionModel
            if nil == sectionModel.newsModelWithEntity(newsModel.entity) {
                sectionModel.changes.insert(newsModel, atIndex: 0)
                let userInfo = ["section": false, "indexPath": NSIndexPath(forRow: 0, inSection: sectionIndex!)]
                
                notifyObserversOfModelDidAdd(userInfo)
            }
        } else {
            //create new SectionModel, add NewsModel to sectionModel; add SectionModel to model
            let sectionModel = LTSectionModel(entities: entities)
            sectionModel.changes.insert(newsModel, atIndex: 0)
            model.changes.insert(sectionModel, atIndex: 0)
            let userInfo = ["section": true, "sectionIndex": 0, "indexPath": NSIndexPath(forRow: 0, inSection: 0)]
            
            notifyObserversOfModelDidAdd(userInfo)
        }
    }
    
    private func notifyObserversOfModelDidAdd(userInfo: [NSObject : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName("changeModelNotification", object: nil, userInfo: userInfo)
        }
    }
    
    //MARK: - ObservableObject
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &observerContext {
            if chagesByBill == nil || chagesByInitiator == nil || chagesByCommittee == nil {
                return
            }
            
            if let newValue = change?[NSKeyValueChangeNewKey] {
                if let bill = newValue as? LTLawModel {
                    if let changeModel = object as? LTChangeModel {
                        processNotification(chagesByBill, changeModel: changeModel, bill: bill, entities: [bill], type: .byLaws)
                        
                        if let initiatorsArray = bill.initiators.allObjects as? [LTInitiatorModel] {
                             processNotification(chagesByInitiator, changeModel: changeModel, bill: bill, entities: initiatorsArray, type: .byInitiators)
                        }
                        
                        processNotification(chagesByCommittee, changeModel: changeModel, bill: bill, entities: [bill.committee], type: .byCommittees)
                    }
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}
