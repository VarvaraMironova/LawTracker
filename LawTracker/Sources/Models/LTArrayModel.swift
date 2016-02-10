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
    var settings    = VTSettingModel()
    var predicate   : NSPredicate!
    var downloadDate: NSDate!
    
    lazy var models: [LTEntityModel] = {
        return self.fetchedResultsController.fetchedObjects as! [LTEntityModel]
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
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    //MARK: - Public
    func filters(key: LTType) -> [LTSectionModel] {
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
        
        for model in models {
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
    
    func changes(completionHandler:(bills: LTChangesModel, committees:  LTChangesModel, initiators:  LTChangesModel, finish: Bool) -> Void) {
        //check are there saved filters. If true -> apply filters
        let billsList = sectionModelsByKey(.byLaws)
        let committeesList = sectionModelsByKey(.byCommittees)
        let initiatorsList = sectionModelsByKey(.byInitiators)

        let byBillsChanges = applyFilters(billsList, key: .byLaws)
        let billsFilterApplied = nil != byBillsChanges
        let byInitiatorsChanges = applyFilters(initiatorsList, key: .byInitiators)
        let initiatorsFilterApplied = nil != byInitiatorsChanges
        let byCommitteesChanges = applyFilters(committeesList, key: .byCommittees)
        let committeesFilterApplied = nil != byCommitteesChanges
        
        let chagesByBill = LTChangesModel(changes: nil == byBillsChanges ? billsList : byBillsChanges, filtersIsApplied: billsFilterApplied, date: downloadDate)
        let chagesByCommittee = LTChangesModel(changes: nil == byCommitteesChanges ? committeesList : byCommitteesChanges, filtersIsApplied: committeesFilterApplied, date: downloadDate)
        let chagesByInitiator = LTChangesModel(changes: nil == byInitiatorsChanges ? initiatorsList : byInitiatorsChanges, filtersIsApplied: initiatorsFilterApplied, date: downloadDate)
        
        completionHandler(bills: chagesByBill, committees:  chagesByCommittee, initiators:  chagesByInitiator, finish: true)
    }
    
    func count() -> Int {
        return models.count
    }
    
    //MARK: - Private
    private func sectionModelsByKey(key: LTType) -> [LTSectionModel]! {
        var result = [LTSectionModel]()
        let changes = models.map(
            {(element: LTEntityModel) -> LTChangeModel in
                return element as! LTChangeModel
        })
        
        for changeModel in changes {
            let bill = changeModel.law
            
            switch key {
            case .byLaws:
                let bills = [bill]
                
                var sectionBillModel = result.filter(){ $0.entities == bills }.first
                if nil == sectionBillModel {
                    sectionBillModel = LTSectionModel(entities: bills)
                    sectionBillModel!.changes.append(changeModel)
                    result.append(sectionBillModel!)
                } else {
                    sectionBillModel!.changes.append(changeModel)
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
                    sectionInitiatorModel!.changes.append(changeModel)
                    result.append(sectionInitiatorModel!)
                } else {
                    sectionInitiatorModel!.changes.append(changeModel)
                }
                
                break
                
            case .byCommittees:
                let committees = [bill.committee]
                var sectionCommitteeModel = result.filter(){ $0.entities == committees }.first
                if nil == sectionCommitteeModel {
                    sectionCommitteeModel = LTSectionModel(entities: committees)
                    sectionCommitteeModel!.changes.append(changeModel)
                    result.append(sectionCommitteeModel!)
                } else {
                    sectionCommitteeModel!.changes.append(changeModel)
                }
                
                break
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
}
