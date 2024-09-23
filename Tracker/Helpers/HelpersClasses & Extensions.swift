//
//  PaddedTextField.swift
//  Tracker
//
//  Created by Anton Demidenko on 13.9.24..
//

import Foundation
import UIKit

class PaddedTextField: UITextField {
    
    let padding: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    
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

class CustomTableViewCell: UITableViewCell {
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YGrayColor")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YBlackColor")
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var separatorTrailingConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(separator)
        
        contentView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        separatorTrailingConstraint = separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -8),
            
            separator.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            separatorTrailingConstraint!,
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        backgroundColor = UIColor(named: "TableViewColor")
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSeparatorHidden(_ hidden: Bool) {
        separator.isHidden = hidden
    }
    
    func configure(with text: String, separatorHidden: Bool) {
        titleLabel.text = text
        setSeparatorHidden(separatorHidden)
    }
    
    func setAccessoryType(_ type: UITableViewCell.AccessoryType) {
        self.accessoryType = type
        
        switch type {
        case .none:
            separatorTrailingConstraint?.constant = -16
        case .disclosureIndicator, .checkmark:
            separatorTrailingConstraint?.constant = 12
        default:
            separatorTrailingConstraint?.constant = -16
        }
        layoutIfNeeded()
    }
}




class ScheduleTableViewCell: CustomTableViewCell {
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String, isSwitchOn: Bool, separatorHidden: Bool) {
        super.configure(with: text, separatorHidden: separatorHidden)
        switchControl.isOn = isSwitchOn
    }
    
}

extension Calendar {
    func isDateInFuture(_ date: Date) -> Bool {
        return date > Date()
    }
}