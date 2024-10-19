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
    static let shared = TrackerCategoryStore()
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    private var trackerStore = TrackerStore.shared
    
    var categories: [TrackerCategory] {
        return fetchCategoriesFromCoreData()
    }
    
    var selectedCategory: TrackerCategory? {
        didSet {
            saveSelectedCategoryToCoreData()
        }
    }
    
    let pinnedCategory: TrackerCategory = TrackerCategory(
            title: "pinned".localized(),
            trackers: []
        )
    
    var onCategoriesUpdated: (() -> Void)?

    // MARK: - Initializers
    
    private override init() {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("Не удалось привести delegate к AppDelegate")
            }
            self.context = appDelegate.persistentContainer.viewContext
            
            do {
                self.trackerStore = try TrackerStore(context: context)
            } catch {
                fatalError("Не удалось инициализировать TrackerStore: \(error)")
            }
            
            super.init()
            setupFetchedResultsController()
        }
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController = controller
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка при выполнении fetch: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    func fetchCategories() -> [TrackerCategory] {
        return fetchCategoriesFromCoreData()
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
            try addNewCategoryToCoreData(category)
    }
    
    func deleteCategory(withTitle title: String) throws {
            try deleteCategoryFromCoreData(withTitle: title)
    }
    
    func saveCategories() {
        saveCategoriesToCoreData()
    }
    
    func loadSelectedCategory() -> TrackerCategory? {
        return loadSelectedCategoryFromCoreData()
    }
    
    func updateSelectedCategory(with title: String?) {
        updateSelectedCategoryInCoreData(with: title)
    }
    
    func notifyUpdates() {
        onCategoriesUpdated?()
    }
    
    // MARK: - Private Methods
    
    private func fetchCategoriesFromCoreData() -> [TrackerCategory] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            print("FetchedResultsController is nil or has no objects")
            return []
        }
        
        do {
            let categories = try objects.map { try self.category(from: $0) }
            return categories
        } catch {
            print("Ошибка при маппинге категорий: \(error)")
            return []
        }
    }
    
    private func addNewCategoryToCoreData(_ category: TrackerCategory) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        let existingCategories = try context.fetch(fetchRequest)
        guard existingCategories.isEmpty else {
            print("Категория с именем \(category.title) уже существует.")
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        let trackerCoreDataList: [TrackerCoreData] = category.trackers.compactMap { tracker in
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
    }
    
    private func deleteCategoryFromCoreData(withTitle title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        let results = try context.fetch(fetchRequest)
        for category in results {
            context.delete(category)
        }
        try context.save()
    }
    
    private func saveCategoriesToCoreData() {
        context.perform {
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    print("Ошибка при сохранении категорий: \(error)")
                }
            }
        }
    }
    
    private func saveSelectedCategoryToCoreData() {
        clearPreviousSelections()
        
        if let selectedCategory = selectedCategory {
            let categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.title = selectedCategory.title
            categoryCoreData.isSelected = true
            
            try? context.save()
        }
    }
    
    private func loadSelectedCategoryFromCoreData() -> TrackerCategory? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSelected == true")
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first.flatMap { try? category(from: $0) }
        } catch {
            print("Ошибка при загрузке выбранной категории: \(error)")
            return nil
        }
    }
    
    private func updateSelectedCategoryInCoreData(with title: String?) {
        clearPreviousSelections()
        
        guard let title = title else { return }
        
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let categoryCoreData = results.first {
                categoryCoreData.isSelected = true
                try context.save()
            }
        } catch {
            print("Ошибка при обновлении выбранной категории: \(error)")
        }
    }
    
    private func clearPreviousSelections() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSelected == true")
        
        do {
            let results = try context.fetch(fetchRequest)
            for category in results {
                category.isSelected = false
            }
            try context.save()
        } catch {
            print("Ошибка при сбросе предыдущих выборов: \(error)")
        }
    }
    
    private func category(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = categoryCoreData.title else {
            throw TrackerStoreError.decodingErrorInvalidTitle
        }
        
        let allTrackers = trackerStore.trackers
        let trackers = (categoryCoreData.tracker as? Set<TrackerCoreData>)?.compactMap { trackerCoreData in
            return allTrackers.first { $0.id == trackerCoreData.id }
        } ?? []
        
        return TrackerCategory(title: title, trackers: trackers)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            notifyUpdates()
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
            guard let newIndexPath = newIndexPath else { return }
                print("Inserted category at \(newIndexPath)")
        case .delete:
            guard let indexPath = indexPath else { return }
                print("Deleted category at \(indexPath)")
        case .update:
            guard let indexPath = indexPath else { return }
            print("Updated category at \(indexPath)")
        default:
            break
        }
    }
}
