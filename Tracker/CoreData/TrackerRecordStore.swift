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
    let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!

    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()

        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }

    var trackerRecords: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let records = try? objects.map({ try self.record(from: $0) })
        else { return [] }
        return records
    }

    func addNewRecord(_ record: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.trackerId = record.trackerId
        trackerRecordCoreData.date = record.date
        try context.save()
    }

    func record(from recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let trackerId = recordCoreData.trackerId else {
            throw TrackerStoreError.decodingErrorInvalidID
        }
        guard let date = recordCoreData.date else {
            throw TrackerStoreError.decodingErrorInvalidDate
        }

        return TrackerRecord(trackerId: trackerId, date: date)
    }
    
    func removeRecord(for trackerId: UUID, on date: Date) throws {
            let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "trackerId == %@ AND date == %@",
                trackerId.uuidString, date as CVarArg
            )

            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object)
            }

            try context.save()
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
