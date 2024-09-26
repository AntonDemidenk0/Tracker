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
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    init?(shortName: String) {
        switch shortName {
        case "Пн": self = .monday
        case "Вт": self = .tuesday
        case "Ср": self = .wednesday
        case "Чт": self = .thursday
        case "Пт": self = .friday
        case "Сб": self = .saturday
        case "Вс": self = .sunday
        default: return nil
        }
    }
}
