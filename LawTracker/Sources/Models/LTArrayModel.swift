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
    
    var changesByBills     : LTChangesModel!
    var changesByInitiators: LTChangesModel!
    var changesByCommittees: LTChangesModel!
    
    var changesSet: Bool = false
    
    lazy var models: [LTEntityModel]! = {
        return self.fetchedResultsController.fetchedObjects as? [LTEntityModel]
    }()
    
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
    
    init(entityName: String, predicate: NSPredicate, date: NSDate) {
        super.init()
        
        self.predicate = predicate
        self.entityName = entityName
        self.downloadDate = date
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
    
    //MARK: - Public
    func filters(key: LTType, completionHandler:(result: [LTSectionModel], finish: Bool) -> Void) {
        if nil == models {
            completionHandler(result: [LTSectionModel](), finish: true)
            return
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
        
        completionHandler(result: filters, finish: true)
    }
    
    func changes(completionHandler:(byBills: LTChangesModel, byInitiators: LTChangesModel, byCommittees: LTChangesModel, finish: Bool) -> Void) {
        let date = downloadDate
        
        if nil == models {
            return
        }
        
        let queue = CoreDataStackManager.coreDataQueue()
        dispatch_async(queue) {[unowned self] in
            let billsList = self.sectionModelsByKey(.byLaws)
            let committeesList = self.sectionModelsByKey(.byCommittees)
            let initiatorsList = self.sectionModelsByKey(.byInitiators)
            
            let byBillsChanges = self.applyFilters(billsList, key: .byLaws)
            let billsFilterApplied = nil != byBillsChanges
            let byInitiatorsChanges = self.applyFilters(initiatorsList, key: .byInitiators)
            let initiatorsFilterApplied = nil != byInitiatorsChanges
            let byCommitteesChanges = self.applyFilters(committeesList, key: .byCommittees)
            let committeesFilterApplied = nil != byCommitteesChanges
            
            let changesByBills = LTChangesModel(changes: nil == byBillsChanges ? billsList : byBillsChanges, filtersApplied: billsFilterApplied, date: date)
            let changesByCommittees = LTChangesModel(changes: nil == byCommitteesChanges ? committeesList : byCommitteesChanges, filtersApplied: committeesFilterApplied, date: date)
            let changesByInitiators = LTChangesModel(changes: nil == byInitiatorsChanges ? initiatorsList : byInitiatorsChanges, filtersApplied: initiatorsFilterApplied, date: date)
            
            self.changesByBills = changesByBills
            self.changesByInitiators = changesByInitiators
            self.changesByCommittees = changesByInitiators
            
            print(self.changesByBills, changesByBills)
            
            completionHandler(byBills: changesByBills, byInitiators: changesByInitiators, byCommittees: changesByCommittees, finish: true)
            
            self.changesSet = true
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
    
    private func createSectionByKey(changeModel: LTChangeModel, key: LTType, completionHandler:(newsModel: LTNewsModel?, sectionModel: LTSectionModel?, finish: Bool) -> Void) {
        let bill = changeModel.law
        if bill.title == "" {
            completionHandler(newsModel: nil, sectionModel: nil, finish: true)
            return
        }
        
        let newsModel = LTNewsModel(entity: changeModel, type: key)
        
        synchronized(self, closure: {
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
        })
    }
    
    private func notifyObserversOfModelsDidInsert(changesModel: LTChangesModel, newsModel: LTNewsModel, sectionModel: LTSectionModel, key: LTType) {
        let existedSectionModel = changesModel.sectionWithEntities(sectionModel.entities)
        var row = 0
        var section = 0
        var userInfo : [NSObject: AnyObject]?
        
        if nil == existedSectionModel {
            changesModel.addModel(sectionModel)
            section = changesModel.count() - 1
            userInfo = ["indexPath": NSIndexPath(forRow: row, inSection: section), "changesModel" : changesModel, "key": key.rawValue]
        } else {
            if nil == existedSectionModel!.newsModelWithEntity(newsModel.entity) {
                existedSectionModel!.addModel(newsModel)
                row = existedSectionModel!.count() - 1
                section = changesModel.changes.indexOf(existedSectionModel!)!
                userInfo = ["indexPath": NSIndexPath(forRow: row, inSection: section), "changesModel" : changesModel, "key": key.rawValue]
            } else {
                userInfo = nil
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("contentDidChange", object: nil, userInfo: userInfo)
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let changeModel = anObject as? LTChangeModel {
            if !changesSet {
                return
            }
            
            for key in LTType.filterTypes {
                createSectionByKey(changeModel, key: key, completionHandler: { (newsModel, sectionModel, finish) -> Void in
                    if let newsModel = newsModel as LTNewsModel! {
                        if let sectionModel = sectionModel as LTSectionModel! {
                            dispatch_async(dispatch_get_main_queue()) {[unowned self] in
                                switch key {
                                case .byLaws:
                                    self.notifyObserversOfModelsDidInsert(self.changesByBills, newsModel: newsModel, sectionModel: sectionModel, key: key)
                                    break
                                    
                                case .byInitiators:
                                    self.notifyObserversOfModelsDidInsert(self.changesByInitiators, newsModel: newsModel, sectionModel: sectionModel, key: key)
                                    break
                                    
                                case .byCommittees:
                                    self.notifyObserversOfModelsDidInsert(self.changesByCommittees, newsModel: newsModel, sectionModel: sectionModel, key: key)
                                    break
                                }
                                
                            }
                        }
                    }
                })
            }
        }
    }
    
}
