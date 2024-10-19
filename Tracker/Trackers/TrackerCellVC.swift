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
    func didUnpinTracker(_ tracker: Tracker)
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
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
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
    
    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "pin")
        imageView.isHidden = true
        return imageView
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
        containerView.addSubview(pinImageView)
        
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
        
        let isPinned = checkIfTrackerIsPinned(tracker)
        pinImageView.isHidden = !isPinned
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
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            pinImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            pinImageView.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            
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
        
        let isPinned = checkIfTrackerIsPinned(tracker)
        let pinActionTitle = isPinned ? "unpin".localized() : "pin".localized()
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let pinAction = UIAction(title: pinActionTitle) { _ in
                if isPinned {
                    self.delegate?.didUnpinTracker(tracker)
                } else {
                    self.delegate?.didPinTracker(tracker)
                }
            }
            
            let editAction = UIAction(title: "edit".localized()) { _ in
                self.delegate?.didEditTracker(tracker)
            }
            
            let deleteAction = UIAction(title: "delete".localized(), attributes: .destructive) { _ in
                self.delegate?.didPushDelete(tracker)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    private func checkIfTrackerIsPinned(_ tracker: Tracker) -> Bool {
        return TrackerCategoryStore.shared.categories.first { category in
            category.title == "pinned".localized() && category.trackers.contains(where: { $0.id == tracker.id })
        } != nil
    }
}
