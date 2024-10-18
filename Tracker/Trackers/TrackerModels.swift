//
//  TrackerModels.swift
//  Tracker
//
//  Created by Anton Demidenko on 9.9.24..
//

import Foundation

struct Tracker: Codable, Hashable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: Set<WeekDay>?
    
    var formattedSchedule: String {
           if let schedule = schedule {
               return schedule.map { $0.displayName }.joined(separator: ", ")
           } else {
               return "Нерегулярное событие"
           }
    }
}

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord: Codable, Hashable, Equatable {
    let trackerId: UUID
    let date: Date
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.trackerId == rhs.trackerId && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
        hasher.combine(Calendar.current.startOfDay(for: date))
    }
}


