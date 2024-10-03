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
    
    var selectedCategory: TrackerCategory? {
        didSet {
            saveSelectedCategory()
        }
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        self.trackerStore = try TrackerStore(context: context)
        super.init()
        
        loadSelectedCategory()
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
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("Ошибка при выполнении fetch: \(error)")
        }
    }
    
    var categories: [TrackerCategory] {
        guard
            let objects = fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.category(from: $0) })
        else { return [] }
        return categories
    }

    func fetchCategories() -> [TrackerCategory] {
        do {
            try setupFetchedResultsController() // Обновляем контроллер перед загрузкой
            return categories
        } catch {
            print("Ошибка при загрузке категорий: \(error)")
            return []
        }
    }

    func addNewCategory(_ category: TrackerCategory) throws {
        print("Adding new category: \(category.title)")
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        // Отладка: Выводим трекеры категории
        print("Trackers in category: \(category.trackers.count)")
        
        let trackerCoreDataList: [TrackerCoreData] = category.trackers.compactMap { tracker -> TrackerCoreData? in
            print("Creating tracker: \(tracker.name) with ID: \(tracker.id)")
            
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.name = tracker.name
            trackerCoreData.color = tracker.color
            trackerCoreData.emoji = tracker.emoji
            
            if let schedule = tracker.schedule {
                print("Encoding schedule: \(schedule)")
                trackerCoreData.schedule = try? JSONEncoder().encode(schedule) as NSData
            } else {
                print("No schedule for tracker: \(tracker.name)")
            }
            
            return trackerCoreData
        }
        
        categoryCoreData.tracker = NSSet(array: trackerCoreDataList)
        
        // Отладка: Выводим количество трекеров в категории
        print("Total trackers added to category \(category.title): \(trackerCoreDataList.count)")
        
        try context.save()
        print("Category '\(category.title)' saved successfully.")
    }
    
    func deleteCategory(withTitle title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        do {
            let results = try context.fetch(fetchRequest)
            for category in results {
                context.delete(category)
            }
            try context.save()
        } catch {
            print("Ошибка при удалении категории: \(error)")
            throw error
        }
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

    func saveCategories() {
        do {
            try context.save()
            print("Категории успешно сохранены.")
        } catch {
            print("Ошибка при сохранении категорий: \(error)")
        }
    }

    func saveSelectedCategory() {
        clearPreviousSelections()

        if let selectedCategory = selectedCategory {
            let categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.title = selectedCategory.title
            categoryCoreData.isSelected = true

            try? context.save()
        }
    }
    
    func loadSelectedCategory() -> TrackerCategory? {
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

    func updateSelectedCategory(with title: String?) {
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
}


extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            print("Moved category from \(oldIndexPath) to \(newIndexPath)")
        @unknown default:
            fatalError("Unknown change type")
        }
    }
}
