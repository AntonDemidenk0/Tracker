//
//  PaddedTextField.swift
//  Tracker
//
//  Created by Anton Demidenko on 26.9.24..
//

import Foundation
import UIKit

final class PaddedTextField: UITextField {
    
    private let padding: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
