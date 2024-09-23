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
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = UIColor(named: "YBlackColor")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(newUsualTracker), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = UIColor(named: "YBlackColor")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(newIrregularTracker), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Создание трекера"
        
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
    
    @objc func newUsualTracker(_ sender: UIButton) {
        let newUsualVC = NewUsualTrackerViewController()
        
        newUsualVC.trackersViewController = self.trackersViewController
        
        newUsualVC.setCompletionHandler { [weak self] newTracker, categoryTitle in
            guard let self = self else { return }
            if let trackersVC = newUsualVC.trackersViewController {
                trackersVC.addTracker(newTracker, toCategoryTitle: categoryTitle)
            }
        }
        
        let navController = UINavigationController(rootViewController: newUsualVC)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true)
    }
    
    @objc func newIrregularTracker(_ sender: UIButton) {
        let newIrregularVC = NewIrregularTrackerViewController()
        
        newIrregularVC.trackersViewController = self.trackersViewController
        
        newIrregularVC.setCompletionHandler { [weak self] newTracker, categoryTitle in
            guard let self = self else { return }
            if let trackersVC = newIrregularVC.trackersViewController {
                trackersVC.addTracker(newTracker, toCategoryTitle: categoryTitle)
            }
        }
        
        let navController = UINavigationController(rootViewController: newIrregularVC)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true)
    }
}

