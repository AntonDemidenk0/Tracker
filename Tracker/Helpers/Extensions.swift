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
        return String.localizedStringWithFormat(NSLocalizedString("days.count", comment: ""), self)
    }
}
extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
