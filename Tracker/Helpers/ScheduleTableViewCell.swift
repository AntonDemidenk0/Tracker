//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Anton Demidenko on 26.9.24..
//

import Foundation
import UIKit

final class ScheduleTableViewCell: CustomTableViewCell {
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
