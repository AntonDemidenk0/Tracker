//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Anton Demidenko on 10.9.24..
//

import Foundation
import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8 
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
    func updateAppearance() {
        if isSelected {
            
            contentView.layer.borderWidth = 3
            
            if let backgroundColor = colorView.backgroundColor {
                contentView.layer.borderColor = backgroundColor.withAlphaComponent(0.3).cgColor
            } else {
                contentView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
            }
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
