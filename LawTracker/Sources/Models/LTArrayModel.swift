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
    
    lazy var models: [LTEntityModel] = {
        return self.fetchedResultsController.fetchedObjects as! [LTEntityModel]
    }()
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(value: true);
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    init(entityName: String) {
        super.init()
        
        self.entityName = entityName
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    //MARK: - Public
    func filters(key: LTType) -> [LTFilterModel] {
        var filters = [LTFilterModel]()
        var filteredIds = [String]()
        let settings = VTSettingModel()
        
        switch key {
        case .byCommittees:
            filteredIds = settings.committees
            break
            
        case .byInitiators:
            filteredIds = settings.initiators
            break
            
        case .byLaws:
            filteredIds = settings.laws
            break
        }
        
        for model in models {
            let filterModel = LTFilterModel(entity: model, selected:filteredIds.contains(model.id))
            filters.append(filterModel)
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
        
        for changeModel in changes {
            var ids = [String]()
            var title = String()
            
            switch key {
            case .byLaws:
                ids = [changeModel.law.id]
                title = changeModel.law.number
                
            case .byInitiators:
                let initiators = changeModel.law.initiators.allObjects as! [LTInitiatorModel]
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
                ids = [changeModel.law.committee.id]
                title = changeModel.law.committee.title
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
        
        let changesModel = LTChangesModel(changes: changesByKey, filtersIsApplied:filteredIds.count > 0, date:NSDate().string("yyyy-MM-dddd"))
        
        return changesModel
    }
}
