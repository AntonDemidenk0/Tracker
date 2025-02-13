//
//  WeekDay.swift
//  Tracker
//
//  Created by Anton Demidenko on 26.9.24..
//

import Foundation

enum WeekDay: Int, CaseIterable, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var displayName: String {
        switch self {
        case .monday: return "monday".localized()
        case .tuesday: return "tuesday".localized()
        case .wednesday: return "wednesday".localized()
        case .thursday: return "thursday".localized()
        case .friday: return "friday".localized()
        case .saturday: return "saturday".localized()
        case .sunday: return "sunday".localized()
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "monday.shortname".localized()
        case .tuesday: return "tuesday.shortname".localized()
        case .wednesday: return "wednesday.shortname".localized()
        case .thursday: return "thursday.shortname".localized()
        case .friday: return "friday.shortname".localized()
        case .saturday: return "saturday.shortname".localized()
        case .sunday: return "sunday.shortname".localized()
        }
    }
    
    init?(shortName: String) {
        switch shortName {
        case "monday.shortname".localized(): self = .monday
        case "tuesday.shortname".localized(): self = .tuesday
        case "wednesday.shortname".localized(): self = .wednesday
        case "thursday.shortname".localized(): self = .thursday
        case "friday.shortname".localized(): self = .friday
        case "saturday.shortname".localized(): self = .saturday
        case "sunday.shortname".localized(): self = .sunday
        default: return nil
        }
    }
}
