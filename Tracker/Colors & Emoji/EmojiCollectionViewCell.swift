//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Anton Demidenko on 10.9.24..
//

import Foundation
import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
        updateAppearance(isSelected: false)
    }
    
    func updateAppearance(isSelected: Bool) {
        if isSelected {
            contentView.backgroundColor = UIColor(named: "EmojiSelectionColor")
        } else {
            contentView.backgroundColor = .clear
        }
    }
}

