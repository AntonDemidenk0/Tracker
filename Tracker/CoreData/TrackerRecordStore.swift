//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Anton Demidenko on 27.9.24..
//

import Foundation
import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    // MARK: - Initializers
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Не удалось получить AppDelegate")
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try self.init(context: context)
        } catch {
            fatalError("Ошибка инициализации TrackerRecordStore: \(error)")
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    
    var trackerRecords: [TrackerRecord] {
        return fetchTrackerRecords()
    }
    
    func addNewRecord(_ record: TrackerRecord) throws {
        try saveNewRecord(record)
    }
    
    func removeRecord(for trackerId: UUID, on date: Date) throws {
        print("Начинаем удаление записи для trackerId: \(trackerId) на дату: \(date)")
        try deleteRecord(for: trackerId, on: date)
    }
    
    // MARK: - Private Methods
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка при выполнении fetch: \(error)")
        }
    }

    private func fetchTrackerRecords() -> [TrackerRecord] {
        guard let fetchedResultsController = fetchedResultsController,
              let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return (try? objects.map { try self.decodeRecord(from: $0) }) ?? []
    }
    
    private func saveNewRecord(_ record: TrackerRecord) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId.uuidString, record.date as CVarArg
        )
        
        let existingRecords = try context.fetch(fetchRequest)
        
        if existingRecords.isEmpty {
            let trackerRecordCoreData = TrackerRecordCoreData(context: context)
            trackerRecordCoreData.trackerId = record.trackerId
            trackerRecordCoreData.date = record.date
            try saveContext()
            print("Добавлена новая запись для trackerId: \(record.trackerId) на дату: \(record.date)")
        } else {
            print("Запись уже существует для trackerId: \(record.trackerId) на дату: \(record.date)")
        }
    }
    
    private func deleteRecord(for trackerId: UUID, on date: Date) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            print("Ошибка при вычислении конца дня для даты: \(date)")
            return
        }
        
        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId.uuidString, startOfDay as NSDate, endOfDay as NSDate
        )
        
        do {
            let objects = try context.fetch(fetchRequest)
            
            if objects.isEmpty {
                print("Запись для удаления не найдена для trackerId: \(trackerId) на дату: \(date)")
            } else {
                for object in objects {
                    print("Удаляется запись: \(object) для trackerId: \(trackerId) на дату: \(date)")
                    context.delete(object)
                }
            }
            
            try saveContext()
        } catch {
            print("Ошибка при выполнении fetch: \(error)")
            throw error
        }
    }

    
    
    private func decodeRecord(from recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let trackerId = recordCoreData.trackerId else {
            throw TrackerStoreError.decodingErrorInvalidID
        }
        guard let date = recordCoreData.date else {
            throw TrackerStoreError.decodingErrorInvalidDate
        }
        return TrackerRecord(trackerId: trackerId, date: date)
    }
    
    private func saveContext() throws {
        do {
            try context.save()
            let objects = fetchedResultsController?.fetchedObjects
            print("Сохранение прошло успешно. Текущие объекты: \(String(describing: objects))")
        } catch {
            print("Ошибка при сохранении контекста: \(error)")
            throw error
        }
    }
}


// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Will change content")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Did change content")
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
            print("Inserted record at \(newIndexPath)")
        case .delete:
            guard let indexPath = indexPath else { return }
            print("Deleted record at \(indexPath)")
        case .update:
            guard let indexPath = indexPath else { return }
            print("Updated record at \(indexPath)")
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            print("Moved record from \(oldIndexPath) to \(newIndexPath)")
        @unknown default:
            fatalError("Unknown change type")
        }
    }
}
