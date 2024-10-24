//
//  CustomLabelView.swift
//  Tracker
//
//  Created by Anton Demidenko on 24.10.24..
//

import UIKit

final class CardCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        return label
    }()
    
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(hex: "#007BFA")?.cgColor ?? UIColor.clear.cgColor,
            UIColor(hex: "#46E69D")?.cgColor ?? UIColor.clear.cgColor,
            UIColor(hex: "#FD4C49")?.cgColor ?? UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 16.0
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 2
        shapeLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 16.0).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer

        layer.addSublayer(gradientLayer)
        
        layer.cornerRadius = 16.0
        layer.masksToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    
    func configure(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
}
