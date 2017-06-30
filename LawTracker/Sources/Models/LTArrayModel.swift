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
    var downloadDate: Date!
    
    lazy var models: [LTEntityModel]! = {
        return self.fetchedResultsController.fetchedObjects
    }()
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<LTEntityModel> in
        let fetchRequest = NSFetchRequest<LTEntityModel>(entityName: self.entityName)
        fetchRequest.predicate = self.predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    init(entityName: String, predicate: NSPredicate, date: Date) {
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
    func filters(_ key: LTType, completionHandler:(_ result: [LTSectionModel], _ finish: Bool) -> Void) {
        if nil == models {
            completionHandler([LTSectionModel](), true)
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
        
        completionHandler(filters, true)
    }
    
    func count() -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    //MARK: - Private
    
}
