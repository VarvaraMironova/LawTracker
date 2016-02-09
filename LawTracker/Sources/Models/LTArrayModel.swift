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
        var filteredIds = [String]()
        let settings = VTSettingModel()
        
        switch key {
        case .byCommittees:
            filters.append(LTSectionModel(title: ""))
            filteredIds = settings.committees
            break
            
        case .byInitiators:
            filters.append(LTSectionModel(title: ""))
            filters.append(LTSectionModel(title: "Народні депутати України"))
            filteredIds = settings.initiators
            break
            
        case .byLaws:
            filters.append(LTSectionModel(title: ""))
            filteredIds = settings.laws
            break
        }
        
        for model in models {
            let filterModel = LTFilterModel(entity: model, selected:filteredIds.contains(model.id))
            
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
    
    func changesByKey(key: LTType) -> LTChangesModel {
        //check are there saved filters. If true -> apply filters
        var changesByKey = [LTSectionModel]()
        var filteredIds = [String]()
        
        switch key {
        case .byLaws:
            filteredIds = settings.laws
            
        case .byInitiators:
            filteredIds = settings.initiators.sort() { $0 > $1 }
            
        case .byCommittees:
            filteredIds = settings.committees
        }
        
        let changes = models.map(
            {(element: LTEntityModel) -> LTChangeModel in
                return element as! LTChangeModel
        })
        
        for var index = 0; index < changes.count; ++index {
            let changeModel = changes[index]
            var ids = [String]()
            var title = String()
            let law = changeModel.law
            
            switch key {
            case .byLaws:
                ids = [law.id]
                title = law.number
            case .byInitiators:
                let initiators = law.initiators.allObjects as! [LTInitiatorModel]
                //changeModel has more than 2 initiators
                if initiators.count > 2 {
                    var titles = [String]()
                    for initiator in initiators {
                        ids.append(initiator.id)
                        titles.append(initiator.title)
                    }
                    
                    title = titles.joinWithSeparator("\n")
                } else {
                    if let initiator = initiators.first {
                        ids = [initiator.id]
                        title = initiator.title
                    }
                }
                
            case .byCommittees:
                ids = [law.committee.id]
                title = law.committee.title
            }
            
            if filteredIds.count > 0 {
                //filters applied -> for every id from ids check, if filteredIds contains it. If true -> create LTSectionModel
                var contains = false
                for id in ids {
                    if filteredIds.contains(id) {
                        contains = true
                    }
                }
                
                if contains {
                    //check if changesByKey array contains sectionModel with title. If true -> add changeModel to sectionModel.changes, else -> append sectionModel to changesByKey
                    var sectionModel = changesByKey.filter(){ $0.title == title }.first
                    
                    if nil == sectionModel {
                        sectionModel = LTSectionModel(title: title)
                        sectionModel!.changes.append(changeModel)
                        changesByKey.append(sectionModel!)
                    } else {
                        sectionModel!.changes.append(changeModel)
                    }
                }
            } else {
                var sectionModel = changesByKey.filter(){ $0.title == title }.first
                
                if nil == sectionModel {
                    sectionModel = LTSectionModel(title: title)
                    sectionModel!.changes.append(changeModel)
                    
                    changesByKey.append(sectionModel!)
                } else {
                    sectionModel!.changes.append(changeModel)
                }
            }
        }

        let changesModel = LTChangesModel(changes: changesByKey, filtersIsApplied:filteredIds.count > 0, date:downloadDate)
        
        return changesModel
    }
    
    func count() -> Int {
        return models.count
    }
    
    func synchronized(lock: AnyObject, closure:() -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}
