//
//  ViewController.swift
//  Tracker
//
//  Created by Anton Demidenko on 5.9.24..
//

import UIKit

final class TrackersViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var trackers: [Tracker] = []
    private var filteredCategories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = [] {
        didSet {
            trackerCategoryStore.saveCategories()
            print("Categories updated: \(categories.count) categories.")
        }
    }
    private var currentDate: Date = Date() {
        didSet {
            print("Текущая дата: \(currentDate)")
            updateUIForTrackers()
        }
    }
    
    private var completedTrackers: Set<TrackerRecord> = []
    
    // MARK: - UI Elements
    
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.placeholder = "Поиск"
        textField.backgroundColor = UIColor(named: "SearchFieldColor") ?? .lightGray
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 24))
        let searchIcon = UIImageView(image: UIImage(named: "Mangnifyingglass"))
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.contentMode = .scaleAspectFit
        iconContainerView.addSubview(searchIcon)
        
        NSLayoutConstraint.activate([
            searchIcon.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            searchIcon.leadingAnchor.constraint(equalTo: iconContainerView.leadingAnchor, constant: 8),
            searchIcon.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: -6.37),
            searchIcon.widthAnchor.constraint(equalToConstant: 16),
            searchIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        textField.leftView = iconContainerView
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        return textField
    }()
    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "MainScreenStub"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = false
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TrackerHeaderView")
        return collectionView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        loadCategories()
        setupNavigationBar()
        loadCompletedTrackers()
        updateUIForTrackers()
        searchTextField.delegate = self
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.addSubview(trackersLabel)
        view.addSubview(searchTextField)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        setupLayout()
        view.addSubview(collectionView)
        setupCollectionViewConstraints()
    }
    
    private func setupNavigationBar() {
        let plusButtonItem = UIBarButtonItem(
            image: UIImage(named: "PlusButton"),
            style: .plain,
            target: self,
            action: #selector(addNewTracker)
        )
        plusButtonItem.tintColor = UIColor(named: "YBlackColor") ?? .black
        
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            picker.widthAnchor.constraint(equalToConstant: 120),
            picker.heightAnchor.constraint(equalToConstant: 35)
        ])
        let datePickerBarButtonItem = UIBarButtonItem(customView: picker)
        navigationItem.leftBarButtonItem = plusButtonItem
        navigationItem.rightBarButtonItem = datePickerBarButtonItem
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            trackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersLabel.heightAnchor.constraint(equalToConstant: 41),
            
            searchTextField.leadingAnchor.constraint(equalTo: trackersLabel.leadingAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setupCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 34),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addNewTracker(_ sender: UIButton) {
        let newTrackerVC = NewTrackerViewController()
        
        if let trackersVC = self.navigationController?.viewControllers.first(where: { $0 is TrackersViewController }) as? TrackersViewController {
            newTrackerVC.trackersViewController = trackersVC
        } else {
            print("TrackersViewController не найден в навигационном стеке")
        }
        let navController = UINavigationController(rootViewController: newTrackerVC)
        self.present(navController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        print("Date picker value changed to: \(currentDate)")
        updateUIForTrackers()
    }
    
    func addTracker(_ tracker: Tracker, toCategoryTitle categoryTitle: String) {
        print("Adding tracker: \(tracker) to category: \(categoryTitle)")
        
        do {
            try trackerStore.addTracker(tracker, to: categoryTitle)
            categories = trackerCategoryStore.categories
            saveCategories()
            loadCategories()
            updateUIForTrackers()
            collectionView.reloadData()
        } catch {
            print("Failed to add tracker: \(error)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = isTrackerCompleted(tracker, on: currentDate)
        
        let completedDaysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        cell.updateDaysLabel(with: completedDaysCount)
        
        cell.delegate = self
        cell.configure(with: tracker, isCompleted: isCompleted, currentDate: currentDate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TrackerHeaderView", for: indexPath) as? TrackerHeaderView else {
            return UICollectionReusableView()
        }
        
        let category = filteredCategories[indexPath.section]
        header.configure(with: category.title)
        return header
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize.zero
        }
        
        let insets = layout.sectionInset
        let spacing = layout.minimumInteritemSpacing
        let totalSpacing = insets.left + insets.right + spacing
        
        let width = (collectionView.bounds.width - totalSpacing) / 2
        
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
}


// MARK: - Tracker Management
extension TrackersViewController {
    
    func completeTracker(tracker: Tracker, date: Date) {
        let trackerRecordStore = TrackerRecordStore()
        let trackerRecord = TrackerRecord(trackerId: tracker.id, date: date)
        let isIrregular = tracker.schedule == nil
        
        if isIrregular {
            if !completedTrackers.contains(trackerRecord) {
                completedTrackers.insert(trackerRecord)
                saveCompletedTrackers()
                print("Нерегулярный трекер завершён: \(trackerRecord)")
            } else {
                print("Нерегулярный трекер уже завершён.")
            }
        } else {
            if !completedTrackers.contains(trackerRecord) {
                completedTrackers.insert(trackerRecord)
                saveCompletedTrackers()
                print("Регулярный трекер завершён: \(trackerRecord)")
            } else {
                print("Регулярный трекер уже завершён на эту дату: \(trackerRecord)")
            }
        }
        
        do {
            try trackerRecordStore.addNewRecord(trackerRecord)
        } catch {
            print("Ошибка при завершении трекера в CoreData: \(error)")
        }
        
        updateUIForTrackers()
        collectionView.reloadData()
    }
    
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        if let schedule = tracker.schedule {
            let trackerRecord = TrackerRecord(trackerId: tracker.id, date: date)
            return completedTrackers.contains(trackerRecord)
        }
        
        if let completionRecord = completedTrackers.first(where: { $0.trackerId == tracker.id }) {
            return date < Calendar.current.date(byAdding: .day, value: 1, to: completionRecord.date) ?? Date()
        }
        
        return false
    }
    
    private func removeTrackerCompletion(_ tracker: Tracker) {
        do {
            try trackerRecordStore.removeRecord(for: tracker.id, on: currentDate)
            updateUIForTrackers()
        } catch {
            print("Ошибка при удалении записи: \(error)")
        }
    }
    
    private func updateUIForTrackers() {
        print("Updating UI for trackers. Current date: \(currentDate)")
        
        let filteredCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                return shouldDisplayTracker(tracker, on: currentDate)
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        if filteredCategories.isEmpty {
            stubImageView.isHidden = false
            stubLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            stubImageView.isHidden = true
            stubLabel.isHidden = true
            collectionView.isHidden = false
        }
        
        self.filteredCategories = filteredCategories
        collectionView.reloadData()
    }
    
    private func shouldDisplayTracker(_ tracker: Tracker, on date: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        if let schedule = tracker.schedule {
            let currentWeekDay = calendar.component(.weekday, from: date)
            guard let selectedWeekDay = WeekDay(rawValue: currentWeekDay == 1 ? 7 : currentWeekDay - 1) else {
                return false
            }
            return schedule.contains(selectedWeekDay)
        } else if let completionRecord = completedTrackers.first(where: { $0.trackerId == tracker.id }) {
            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: completionRecord.date) ?? Date()
            return date >= completionRecord.date && date < nextDay
        }
        return true
    }
}

// MARK: - Data Persistence
extension TrackersViewController: TrackerCellDelegate {
    
    private func saveCategories() {
        do {
            let existingCategories = trackerCategoryStore.fetchCategories()
            for category in categories {
                if !existingCategories.contains(where: { $0.title == category.title }) {
                    try trackerCategoryStore.addNewCategory(category)
                }
            }
            trackerCategoryStore.saveCategories()
        } catch {
            print("Ошибка при сохранении категорий: \(error)")
        }
    }
    
    func loadCategories() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
            collectionView.reloadData()
        } catch {
            print("Ошибка при загрузке категорий: \(error)")
        }
    }
    
    private func saveCompletedTrackers() {
        let trackerRecordStore = TrackerRecordStore()
        
        for trackerRecord in completedTrackers {
            do {
                try trackerRecordStore.addNewRecord(trackerRecord)
            } catch {
                print("Ошибка при сохранении записи: \(error)")
            }
        }
        
        print("Сохранено в CoreData: \(completedTrackers)")
    }
    
    private func loadCompletedTrackers() {
        let trackerRecordStore = TrackerRecordStore()
        
        completedTrackers = Set(trackerRecordStore.trackerRecords)
        print("Загружено из CoreData: \(completedTrackers)")
    }
    
    // MARK: - Delegate Methods
    
    func didToggleCompletion(for tracker: Tracker, on date: Date) {
        print("Трекер \(tracker.name) отмечен на дату \(date)")
        let trackerRecord = TrackerRecord(trackerId: tracker.id, date: date)
        
        if completedTrackers.contains(trackerRecord) {
            completedTrackers.remove(trackerRecord)
            print("Трекер удалён из completedTrackers")
            
            do {
                try trackerRecordStore.removeRecord(for: tracker.id, on: date)
            } catch {
                print("Ошибка удаления записи из Core Data: \(error)")
            }
        } else {
            completedTrackers.insert(trackerRecord)
            print("Трекер добавлен в completedTrackers")
            
            do {
                try trackerRecordStore.addNewRecord(trackerRecord)
            } catch {
                print("Ошибка добавления записи в Core Data: \(error)")
            }
        }
        
        saveCompletedTrackers()
        
        updateUIForTrackers()
    }
    
}
