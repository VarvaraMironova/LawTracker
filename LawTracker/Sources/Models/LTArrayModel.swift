//
//  LTArrayModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/6/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData
import Foundation

enum LTChangeType : Int {
    case byCommittees = 0, byInitiators = 1, byLaws = 2
    
    static let changesTypes = [byCommittees, byInitiators, byLaws]
}

class LTArrayModel: NSObject, NSFetchedResultsControllerDelegate {
    var settings = VTSettingModel()
    
    var entityName : String!
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: self.entityName)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = NSPredicate(value: true);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    lazy var models: [LTChangeModel] = {
        return self.fetchedResultsController.fetchedObjects as! [LTChangeModel]
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
    func changesByKey(key: LTChangeType) ->[LTSectionModel] {
        //check are there saved filters. If false -> return models, else -> apply filters
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
        
        for changeModel in models {
            var ids = [String]()
            var title = String()
            
            switch key {
            case .byLaws:
                ids = [changeModel.law.id]
                title = changeModel.law.title
                
            case .byInitiators:
                for initiator in changeModel.law.initiators.allObjects {
                    ids.append(initiator.id)
                    title.appendContentsOf(initiator.title + "\n")
                }
                
            case .byCommittees:
                ids = [changeModel.law.committee.id]
                title = changeModel.law.committee.title
            }
            
            //check if changesByKey array contains sectionModel with title==title. If true -> add changeModel to sectionModel.changes, else -> append sectionModel to changesByKey
            var sectionModel = changesByKey.filter(){ $0.title == title }.first
            
            if nil == sectionModel {
                sectionModel = LTSectionModel(title: title)
            }
            
            sectionModel!.changes.append(changeModel)
            
            if filteredIds.count > 0 {
                //filters applied -> for every id from ids check, if filteredIds contains it. If true -> create LTSectionModel
                var contains = false
                for id in ids {
                    if filteredIds.contains(id) {
                        contains = true
                    }
                }
                
                if contains {
                    changesByKey.append(sectionModel!)
                }
            } else {
                //filters not applied ->
                changesByKey.append(sectionModel!)
            }
            
        }
        
        return changesByKey
    }
    
    //MARK: - NSFetchedResultControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("controllerWillChangeContent")
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        print("controller: didChangeObject anObject: ")
        switch(type) {
        case .Insert:
            
            break
            
        case .Delete:
            
            break
            
        case .Update:
            
            break
            
        case .Move:
            
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        print("controller:didChangeSection sectionInfo:")
        switch(type) {
        case .Insert:
            
            break
            
        case .Delete:
            
            break
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("controllerDidChangeContent")
    }
    
    func sectionsCount() ->Int {
        return fetchedResultsController.sections!.count
    }
    
    func rowsInSection() ->Int {
        if let objects = fetchedResultsController.fetchedObjects {
            return objects.count
        }
        
        return 0
    }
}
