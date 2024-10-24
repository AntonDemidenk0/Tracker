//
//  Colors.swift
//  Tracker
//
//  Created by Anton Demidenko on 25.9.24..
//

import Foundation
import UIKit

enum AppColor: String, CaseIterable {
    case CRed
    case COrange
    case CBlue
    case CViolet
    case CGreen
    case CPink
    case CPigPink
    case CLightBlue
    case CSalad
    case CDarkViolet
    case CLightRed
    case CLightPink
    case CYellow
    case CPastelBlue
    case COneMoreViolet
    case CAnotherOneViolet
    case CVioletBlue
    case CBrightGreen

    var color: UIColor {
        return UIColor(named: self.rawValue) ?? UIColor.clear
    }
}
