//
//  TrackerCellVC.swift
//  Tracker
//
//  Created by Anton Demidenko on 23.9.24..
//

import Foundation
import UIKit

// MARK: - Protocol

protocol TrackerCellDelegate: AnyObject {
    func didToggleCompletion(for tracker: Tracker, on date: Date)
    func didPinTracker(_ tracker: Tracker)
    func didEditTracker(_ tracker: Tracker)
    func didPushDelete(_ tracker: Tracker)
    }

// MARK: - TrackerCell

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private var tracker: Tracker?
    private var currentDate: Date?
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - UI Elements
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var footerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0 дней"
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
        
        let checkmarkAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        let checkmarkString = NSAttributedString(string: "✓", attributes: checkmarkAttributes)
        
        button.setAttributedTitle(checkmarkString, for: .selected)
        button.isEnabled = true
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    private var originalButtonColor: UIColor?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(emojiLabel)
        
        contentView.addSubview(footerView)
        footerView.addSubview(daysLabel)
        footerView.addSubview(actionButton)
        
        setupLayout()
        setupContextMenuInteraction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContextMenuInteraction()
    }
    
    private func setupContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        containerView.addInteraction(interaction)
    }
    
    // MARK: - Configure Cell
    
    func configure(with tracker: Tracker, isCompleted: Bool, currentDate: Date) {
        self.tracker = tracker
        self.currentDate = currentDate
        
        nameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        
        if let backgroundColor = UIColor(named: tracker.color) {
            containerView.backgroundColor = backgroundColor
            actionButton.backgroundColor = backgroundColor
        } else {
            containerView.backgroundColor = .gray
            actionButton.backgroundColor = .gray
        }
        
        if isCompleted {
            actionButton.setTitle("✓", for: .normal)
            actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            actionButton.backgroundColor = containerView.backgroundColor?.withAlphaComponent(0.3)
            actionButton.isSelected = true
        } else {
            actionButton.setTitle("+", for: .normal)
            actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
            actionButton.backgroundColor = containerView.backgroundColor
            actionButton.isSelected = false
        }
    }
    
    // MARK: - Layout Setup
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            footerView.heightAnchor.constraint(equalToConstant: 34),
            
            daysLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            daysLabel.heightAnchor.constraint(equalToConstant: 20),
            
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
            actionButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -12),
            actionButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
    }
    
    // MARK: - Button Action
    
    @objc private func didTapButton(_ sender: UIButton) {
        guard let tracker = tracker, let currentDate = currentDate else { return }
        
        if Calendar.current.isDateInFuture(currentDate) {
            print("Нельзя отметить трекер для будущей даты")
            return
        }
        
        delegate?.didToggleCompletion(for: tracker, on: currentDate)
        
        if !sender.isSelected {
            sender.setTitle("✓", for: .normal)
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            sender.backgroundColor = originalButtonColor?.withAlphaComponent(0.3)
            sender.isSelected = true
        } else {
            sender.setTitle("+", for: .normal)
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
            sender.backgroundColor = originalButtonColor
            sender.isSelected = false
        }
        
        let currentDays = Int(daysLabel.text?.components(separatedBy: " ").first ?? "0") ?? 0
        updateDaysLabel(with: sender.isSelected ? currentDays + 1 : max(currentDays - 1, 0))
    }
    
    // MARK: - Update Days Label
    
    func updateDaysLabel(with count: Int) {
        daysLabel.text = count.formatDays()
    }
}

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let tracker = self.tracker else {
            return nil
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in

            let pinAction = UIAction(title: "Закрепить", image: UIImage(systemName: "pin")) { _ in
                self.delegate?.didPinTracker(tracker)
            }

            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.delegate?.didEditTracker(tracker)
            }

            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.delegate?.didPushDelete(tracker)
            }

            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}
