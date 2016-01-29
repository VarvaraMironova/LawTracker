//
//  LTChangesModel.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/6/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import CoreData
import Foundation

class LTChangesModel: NSObject, NSFetchedResultsControllerDelegate {
    var settings = VTSettingModel()
    
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "LTChangeModel")
        
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
    
    override init() {
        super.init()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    //MARK: - Public
    func changesByKey(key: LTFilterType) ->[LTSectionModel] {
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
        
        for changeModel in models {
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
    
}
