//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Anton Demidenko on 10.9.24.
//

import UIKit

// MARK: - NewTrackerViewController

final class NewTrackerViewController: UIViewController {
    var trackersViewController: TrackersViewController?
    
    // MARK: - UI Elements
    
    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.HabitButton.title, for: .normal)
        button.backgroundColor = UIColor(named: "YBlackColor")
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(newUsualTracker), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.IrregularEventButton.title, for: .normal)
        button.backgroundColor = UIColor(named: "YBlackColor")
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(newIrregularTracker), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyBackgroundColor()
        navigationItem.title = L10n.NewTrackerNavItem.title
        
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        
        setupLayout()
    }
    
    // MARK: - Layout Setup
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 20)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func newUsualTracker(_ sender: UIButton) {
        let newUsualVC = NewUsualTrackerViewController()
        newUsualVC.trackersViewController = self.trackersViewController
        
        newUsualVC.setCompletionHandler { [weak self] newTracker, categoryTitle in
            guard let self = self else { return }
            self.trackersViewController?.addTracker(newTracker, toCategoryTitle: categoryTitle)
        }
        
        newUsualVC.setCloseNewTrackerVCHandler { [weak self] in
            self?.dismiss(animated: true)
        }
        
        let navController = UINavigationController(rootViewController: newUsualVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    @objc private func newIrregularTracker(_ sender: UIButton) {
        let newIrregularVC = NewIrregularTrackerViewController()
        newIrregularVC.trackersViewController = self.trackersViewController
        
        newIrregularVC.setCompletionHandler { [weak self] newTracker, categoryTitle in
            guard let self = self else { return }
            self.trackersViewController?.addTracker(newTracker, toCategoryTitle: categoryTitle)
        }
        
        newIrregularVC.setCloseNewTrackerVCHandler { [weak self] in
            self?.dismiss(animated: true)
        }
        
        let navController = UINavigationController(rootViewController: newIrregularVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
}
