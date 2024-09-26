//
//  PaddedTextField.swift
//  Tracker
//
//  Created by Anton Demidenko on 13.9.24..
//

import Foundation
import UIKit

extension Calendar {
    func isDateInFuture(_ date: Date) -> Bool {
        return date > Date()
    }
}

extension Int {
    func formatDays() -> String {
        let absCount = abs(self) % 100
        let lastDigit = absCount % 10
        
        if (11...14).contains(absCount) {
            return "\(self) дней"
        }
        switch lastDigit {
        case 1:
            return "\(self) день"
        case 2, 3, 4:
            return "\(self) дня"
        default:
            return "\(self) дней"
        }
    }
}
