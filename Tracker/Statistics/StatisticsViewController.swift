//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Anton Demidenko on 19.9.24..
//

import Foundation
import UIKit

final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore = TrackerRecordStore.shared
    private lazy var completedTrackers: Int = {
        trackerRecordStore.calculateCompletedTrackers()
    }()
    
    private lazy var bestStreak: Int = {
        trackerRecordStore.calculateBestStreak()
    }()
    
    private lazy var idealDays: Int = {
        trackerRecordStore.calculateIdealDays(for: [])
    }()
    
    private lazy var averageCompletion: Int = {
        trackerRecordStore.calculateAverageCompletion()
    }()
    
    private lazy var statisticsLabel: UILabel = {
        let label = UILabel()
        label.text = "statistics".localized()
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 90)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: "CardCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "StatisticsStubImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "nothing_to_analyze".localized()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var hasData: Bool {
        return completedTrackers > 0 || bestStreak > 0 || idealDays > 0 || averageCompletion > 0
    }
    
    private var cardTitles: [String] {
        return [
            "\(bestStreak)",
            "\(idealDays)",
            "\(completedTrackers)",
            "\(averageCompletion)"
        ]
    }
    
    private let cardContents = ["bestPeriod".localized(),
                                "idealDays".localized(),
                                "trackersCompleted".localized(),
                                "averageValue".localized()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        trackerRecordStore.onRecordsUpdated = { [weak self] in
            self?.updateStatistics()
            print("statistics updated")
        }
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        view.addSubview(statisticsLabel)
        view.addSubview(collectionView)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        
        NSLayoutConstraint.activate([
            statisticsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            statisticsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: statisticsLabel.bottomAnchor, constant: 77),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    func updateView() {
        if hasData {
            collectionView.isHidden = false
            stubImageView.isHidden = true
            stubLabel.isHidden = true
            collectionView.reloadData()
        } else {
            collectionView.isHidden = true
            stubImageView.isHidden = false
            stubLabel.isHidden = false
        }
    }
    
    private func updateStatistics() {
        completedTrackers = trackerRecordStore.calculateCompletedTrackers()
        bestStreak = trackerRecordStore.calculateBestStreak()
        idealDays = trackerRecordStore.calculateIdealDays(for: [])
        averageCompletion = trackerRecordStore.calculateAverageCompletion()
        
        updateView()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension StatisticsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hasData ? cardTitles.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        cell.configure(title: cardTitles[indexPath.item], content: cardContents[indexPath.item])
        return cell
    }
}
