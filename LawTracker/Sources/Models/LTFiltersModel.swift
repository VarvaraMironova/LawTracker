//
//  LTFiltersModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/26/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData
import Foundation

class LTFiltersModel: NSObject, NSFetchedResultsControllerDelegate {
    var entityName : String!
    
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
    
    func fetchEntities(key: LTFilterType) {
        var entityName = String()
        switch key {
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
        
        self.entityName = entityName
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    func filters(key: LTFilterType) -> [LTFilterModel] {
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
}
