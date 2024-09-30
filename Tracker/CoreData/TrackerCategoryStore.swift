//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Anton Demidenko on 27.9.24..
//

import Foundation
import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    private let trackerStore: TrackerStore
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        self.trackerStore = try TrackerStore(context: context)
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    var categories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.category(from: $0) })
        else { return [] }
        return categories
    }

    func addNewCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        let trackerCoreDataList: [TrackerCoreData] = category.trackers.compactMap { tracker -> TrackerCoreData? in
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.name = tracker.name
            trackerCoreData.color = tracker.color
            trackerCoreData.emoji = tracker.emoji
            
            if let schedule = tracker.schedule {
                trackerCoreData.schedule = try? JSONEncoder().encode(schedule) as NSData
            }
            
            return trackerCoreData
        }
        
        categoryCoreData.tracker = NSSet(array: trackerCoreDataList)
        
        try context.save()
    }

    func category(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = categoryCoreData.title else {
            throw TrackerStoreError.decodingErrorInvalidTitle
        }

        let trackers = categoryCoreData.tracker?.compactMap { trackerCoreData in
            return try? trackerStore.tracker(from: trackerCoreData as! TrackerCoreData)
        } ?? []

        return TrackerCategory(title: title, trackers: trackers)
    }
}
