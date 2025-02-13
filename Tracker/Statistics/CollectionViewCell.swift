//
//  CustomLabelView.swift
//  Tracker
//
//  Created by Anton Demidenko on 24.10.24..
//

import UIKit

final class CardCollectionViewCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        return label
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(hex: "#007BFA")?.cgColor ?? UIColor.clear.cgColor,
            UIColor(hex: "#46E69D")?.cgColor ?? UIColor.clear.cgColor,
            UIColor(hex: "#FD4C49")?.cgColor ?? UIColor.clear.cgColor
        ]
        gradient.locations = [0, 0.5, 1]
        gradient.startPoint = CGPoint(x: 1, y: 0.5)
        gradient.endPoint = CGPoint(x: 0, y: 0.5)
        gradient.cornerRadius = 16.0
        return gradient
    }()
    
    private lazy var shapeLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        return shape
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        gradientLayer.frame = bounds
        shapeLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 16.0).cgPath
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
