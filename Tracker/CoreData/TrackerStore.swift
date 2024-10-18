//
//  TrackerStore.swift
//  Tracker
//
//  Created by Anton Demidenko on 27.9.24..
//

import Foundation
import CoreData
import UIKit

enum TrackerStoreError: Error {
    case decodingErrorInvalidID
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedule
    case decodingErrorInvalidDate
    case decodingErrorInvalidTitle
}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    static let shared = TrackerStore()
    // MARK: - Initializers
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to retrieve AppDelegate")
        }
        self.init(context: appDelegate.persistentContainer.viewContext)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    
    var trackers: [Tracker] {
        return fetchedTrackers()
    }
    
    func saveTrackers() {
        saveTrackersToCoreData()
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        try addTrackerToCategory(tracker, categoryTitle: categoryTitle)
        try saveContext()
    }
    
    func updateTracker(_ tracker: Tracker) throws {
        try editTrackerInCoreData(tracker)
        try saveContext()
    }
    
    func deleteTracker(withId id: UUID) throws {
        print("deleteTracker вызывается")
        try removeTrackerFromCoreData(id: id)
        try saveContext()
    }
    
    func pin(_ tracker: Tracker) throws {
        do {
            let trackerToPin = tracker
            try pinTracker(trackerToPin)
        } catch {
            print("Ошибка при закреплении трекера: \(error)")
        }
    }
    
    func pinnedTrackers(title: String) -> [Tracker] {
        do {
            return try fetchPinnedTrackers(for: title)
        } catch {
            print("Ошибка при получении трекеров для категории \(title): \(error)")
            return []
        }
    }
    
    // MARK: - Private Methods
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        fetchedResultsController = controller
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    private func fetchCategoriesCoreData() throws -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    private func fetchedTrackers() -> [Tracker] {
        guard let fetchedResultsController = fetchedResultsController,
              let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return objects.compactMap { try? tracker(from: $0) }
    }
    
    private func fetchPinnedTrackers(for categoryTitle: String) throws -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        let categories = try context.fetch(fetchRequest)
        
        guard let category = categories.first,
              let coreDataTrackers = category.tracker as? Set<TrackerCoreData> else {
            return []
        }
        
        return coreDataTrackers.compactMap { try? tracker(from: $0) }
    }
    
    private func addTrackerToCategory(_ tracker: Tracker, categoryTitle: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        if let category = try context.fetch(fetchRequest).first {
            if category.tracker?.contains(where: { ($0 as? TrackerCoreData)?.id == tracker.id }) == true {
                print("Tracker with id \(tracker.id) already exists in category \(category.title)")
                return
            }
            try createTrackerCoreData(tracker, in: category)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = categoryTitle
            try createTrackerCoreData(tracker, in: newCategory)
        }
    }
    
    private func saveTrackersToCoreData() {
        context.perform {
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    print("Ошибка при сохранении трекеров: \(error)")
                }
            }
        }
    }
    
    private func createTrackerCoreData(_ tracker: Tracker, in category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        
        if let schedule = tracker.schedule {
            trackerCoreData.schedule = try JSONEncoder().encode(schedule) as NSData
        }
        
        trackerCoreData.category = category
    }
    
    private func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else {
            throw TrackerStoreError.decodingErrorInvalidID
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let color = trackerCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        
        var days: Set<WeekDay>? = nil
        if let scheduleData = trackerCoreData.schedule as? Data {
            do {
                days = try JSONDecoder().decode(Set<WeekDay>.self, from: scheduleData)
            } catch {
                throw TrackerStoreError.decodingErrorInvalidSchedule
            }
        }
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: days
        )
    }
    
    private func editTrackerInCoreData(_ tracker: Tracker) throws {
            let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
            
            guard let trackerCoreData = try context.fetch(fetchRequest).first else {
                throw TrackerStoreError.decodingErrorInvalidID
            }
            
            trackerCoreData.name = tracker.name
            trackerCoreData.color = tracker.color
            trackerCoreData.emoji = tracker.emoji
            
            if let schedule = tracker.schedule {
                trackerCoreData.schedule = try JSONEncoder().encode(schedule) as NSData
            } else {
                trackerCoreData.schedule = nil
            }
        }

        private func removeTrackerFromCoreData(id: UUID) throws {
            let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            guard let trackerToDelete = try context.fetch(fetchRequest).first else {
                throw TrackerStoreError.decodingErrorInvalidID
            }
            
            context.delete(trackerToDelete)
        }
    
    private func pinTracker(_ tracker: Tracker) throws {
        let pinnedCategoryTitle = "Закрепленные"
        
        try addTrackerToCategory(tracker, categoryTitle: pinnedCategoryTitle)
    }
    
    
    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let inserted = insertedIndexes ?? []
        let deleted = deletedIndexes ?? []
        let updated = updatedIndexes ?? []
        let moved = movedIndexes ?? []
        
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: inserted,
                deletedIndexes: deleted,
                updatedIndexes: updated,
                movedIndexes: moved
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}

