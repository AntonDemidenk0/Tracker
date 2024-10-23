//
//  ViewController.swift
//  Tracker
//
//  Created by Anton Demidenko on 5.9.24..
//

import UIKit

final class TrackersViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    private let trackerStore = TrackerStore.shared
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private let trackerRecordStore = TrackerRecordStore()
    private lazy var colorVC = ColorViewController()
    private lazy var emojiVC = EmojiViewController()
    private var trackers: Set<Tracker> = [] {
        didSet {
            updateUIForTrackers()
            trackerStore.saveTrackers()
        }
    }
    private var displayedTrackers: [Tracker] = []
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
    private var originalCategories: [UUID: String] = [:] {
        didSet {
            saveOriginalCategoriesToUserDefaults()
        }
    }
    private var currentFilter: String?
    
    private var completedTrackers: Set<TrackerRecord> = []
    private var pinnedTrackers: Set<Tracker> = []
    
    // MARK: - UI Elements
    
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.text = "trackers".localized()
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField()
        searchTextField.font = UIFont.systemFont(ofSize: 17)
        searchTextField.placeholder = "search".localized()
        searchTextField.backgroundColor = UIColor(named: "SearchFieldColor") ?? .lightGray
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.layer.cornerRadius = 8
        searchTextField.clipsToBounds = true
        
        // Добавляем обработчик изменения текста
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
        
        return searchTextField
    }()

    @objc private func searchTextFieldDidChange(_ textField: UISearchTextField) {
        updateUIForTrackers()
    }

    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "MainScreenStub"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = false
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "emptyState.title".localized()
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
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TrackerHeaderView")
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filtersVC), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyBackgroundColor()
        setupUI()
        loadCategories()
        setupNavigationBar()
        loadCompletedTrackers()
        loadPinnedTrackers()
        loadOriginalCategoriesFromUserDefaults()
        updateUIForTrackers()
        searchTextField.delegate = self
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.addSubview(trackersLabel)
        view.addSubview(searchTextField)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        view.addSubview(filterButton)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        setupLayout()
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
        picker.locale = Locale.current
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            picker.widthAnchor.constraint(equalToConstant: 120),
            picker.heightAnchor.constraint(equalToConstant: 35)
        ])
        let datePickerBarButtonItem = UIBarButtonItem(customView: picker)
        datePickerBarButtonItem.tintColor = .clear
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
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
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
    
    @objc private func filtersVC(_ sender: UIButton) {
        let filtersVC = FiltersViewController()
        filtersVC.delegate = self
        let navController = UINavigationController(rootViewController: filtersVC)
        present(navController, animated: true, completion: nil)
    }
    
    func addTracker(_ tracker: Tracker, toCategoryTitle categoryTitle: String) {
        print("Adding tracker: \(tracker) to category: \(categoryTitle)")
        
        do {
            try trackerStore.addTracker(tracker, to: categoryTitle)
            originalCategories[tracker.id] = categoryTitle
            categories = trackerCategoryStore.categories
            saveCategories()
            loadCategories()
            updateUIForTrackers()
            collectionView.reloadData()
        } catch {
            print("Failed to add tracker: \(error)")
        }
    }
    
    func updateTracker(_ tracker: Tracker, toCategoryTitle categoryTitle: String) {
        originalCategories[tracker.id] = categoryTitle
        categories = trackerCategoryStore.categories
        saveCategories()
        loadCategories()
        updateUIForTrackers()
        collectionView.reloadData()
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
            return Calendar.current.isDate(date, inSameDayAs: completionRecord.date)
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
        let searchText = searchTextField.text?.lowercased() ?? ""
        print("Updating UI for trackers. Current date: \(currentDate), search text: \(searchText)")
        
        let filteredCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSearchText = searchText.isEmpty || tracker.name.lowercased().contains(searchText)
                return matchesSearchText && shouldDisplayTracker(tracker, on: currentDate)
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        if filteredCategories.isEmpty {
            stubImageView.isHidden = false
            stubLabel.isHidden = false
            collectionView.isHidden = true
            filterButton.isHidden = true
        } else {
            stubImageView.isHidden = true
            stubLabel.isHidden = true
            collectionView.isHidden = false
            filterButton.isHidden = false
        }
        
        self.filteredCategories = filteredCategories
        sortCategories()
        collectionView.reloadData()
    }

    
    private func shouldDisplayTracker(_ tracker: Tracker, on date: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        var currentDate = date
        
        if currentFilter == "trackers_today".localized() {
            let today = Date()
            currentDate = today
            if let datePicker = navigationItem.rightBarButtonItem?.customView as? UIDatePicker {
                datePicker.setDate(today, animated: true)
            }
        }
        
        if let schedule = tracker.schedule {
            let currentWeekDay = calendar.component(.weekday, from: currentDate)
            guard let selectedWeekDay = WeekDay(rawValue: currentWeekDay == 1 ? 7 : currentWeekDay - 1) else {
                return false
            }
            let isScheduled = schedule.contains(selectedWeekDay)
            
            if currentFilter == "completed".localized() {
                return isScheduled && isTrackerCompleted(tracker, on: currentDate)
            } else if currentFilter == "not_completed".localized() {
                return isScheduled && !isTrackerCompleted(tracker, on: currentDate)
            }
            
            return isScheduled
        } else if let completionRecord = completedTrackers.first(where: { $0.trackerId == tracker.id }) {
            let isCompletedToday = Calendar.current.isDate(currentDate, inSameDayAs: completionRecord.date)
            
            if currentFilter == "completed".localized() {
                return isCompletedToday
            } else if currentFilter == "not_completed".localized() {
                return !isCompletedToday
            }
            
            return isCompletedToday
        }
        
        return true
    }
    
    
    private func saveOriginalCategoriesToUserDefaults() {
        let data = try? JSONEncoder().encode(originalCategories)
        UserDefaults.standard.set(data, forKey: "OriginalCategories")
    }
    
    private func loadOriginalCategoriesFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "OriginalCategories"),
           let categories = try? JSONDecoder().decode([UUID: String].self, from: data) {
            originalCategories = categories
        } else {
            originalCategories = [:]
        }
    }
    
    private func sortCategories() {
        if let pinnedCategoryIndex = filteredCategories.firstIndex(where: { $0.title == "pinned".localized() }) {
            let pinnedCategory = filteredCategories[pinnedCategoryIndex]
            
            if !pinnedCategory.trackers.isEmpty {
                filteredCategories.remove(at: pinnedCategoryIndex)
                filteredCategories.insert(pinnedCategory, at: 0)
            }
        }
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
    
    func didPinTracker(_ tracker: Tracker) {
        do {
            try pin(tracker)
            print("Трекер \(tracker.name) закреплен")
        } catch {
            print("Ошибка при попытке закрепить трекер: \(error)")
        }
        loadCategories()
        updateUIForTrackers()
    }
    
    func didUnpinTracker(_ tracker: Tracker) {
        do {
            try unpin(tracker)
            print("Трекер \(tracker.name) откреплен")
        } catch {
            print("Ошибка при попытке открепить трекер: \(error)")
        }
        loadCategories()
        updateUIForTrackers()
    }
    
    func isTrackerPinned(_ tracker: Tracker) -> Bool {
        if let category = getCategory(for: tracker.id) {
            return category == "pinned".localized()
        }
        return false
    }
    
    func getCategory(for trackerId: UUID) -> String? {
        let allCategories = trackerCategoryStore.fetchCategories()
        
        for category in allCategories {
            if category.trackers.contains(where: { $0.id == trackerId }) {
                return category.title
            }
        }
        return nil
    }
    
    func pin(_ tracker: Tracker) throws {
        
        try trackerStore.deleteTracker(withId: tracker.id)
        
        let pinnedTracker = Tracker(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule)
        try trackerStore.addTracker(pinnedTracker, to: "pinned".localized())
    }
    
    func unpin(_ tracker: Tracker) throws {
        try trackerStore.deleteTracker(withId: tracker.id)
        
        if let originalCategoryTitle = originalCategories[tracker.id] {
            let unpinnedTracker = Tracker(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule)
            try trackerStore.addTracker(unpinnedTracker, to: originalCategoryTitle)
        }
    }
    
    func didEditTracker(_ tracker: Tracker) {
        let categoryTitle = getCategory(for: tracker.id)
        
        if tracker.schedule != nil {
            
            let editTrackerVC = EditTrackerViewController()
            editTrackerVC.selectedCategory = categoryTitle
            editTrackerVC.trackerNameTextField.text = tracker.name
            editTrackerVC.trackerName = tracker.name
            editTrackerVC.trackerId = tracker.id
            
            if let color = UIColor(named: tracker.color) {
                editTrackerVC.selectedColor = color
                print("Цвет успешно найден: \(color)")
            } else {
                print("Ошибка: не удалось найти цвет с именем \(tracker.color)")
            }
            
            editTrackerVC.selectedEmoji = tracker.emoji
            editTrackerVC.selectedDaysString = formatDays(tracker.schedule ?? [])
            
            let numberOfDaysCompleted = trackerRecordStore.countDaysCompleted(for: tracker.id)
            editTrackerVC.daysLabel.text = "\(numberOfDaysCompleted.formatDays())"
            print("\(numberOfDaysCompleted.formatDays())")
            
            editTrackerVC.setCompletionHandler { [weak self] editedTracker, categoryTitle in
                guard let self = self else { return }
                print("Вызов completionHandler перед созданием трекера")
                self.updateTracker(tracker, toCategoryTitle: categoryTitle)
                print("completionHandler вызван успешно")
            }
            
            let navController = UINavigationController(rootViewController: editTrackerVC)
            self.present(navController, animated: true, completion: nil)
            
        } else {
            
            let editIrregularTrackerVC = EditIrregularTrackerViewController()
            editIrregularTrackerVC.selectedCategory = categoryTitle
            editIrregularTrackerVC.trackerNameTextField.text = tracker.name
            editIrregularTrackerVC.trackerName = tracker.name
            editIrregularTrackerVC.trackerId = tracker.id
            
            if let color = UIColor(named: tracker.color) {
                editIrregularTrackerVC.selectedColor = color
                print("Цвет успешно найден: \(color)")
            } else {
                print("Ошибка: не удалось найти цвет с именем \(tracker.color)")
            }
            
            editIrregularTrackerVC.selectedEmoji = tracker.emoji
            
            let numberOfDaysCompleted = trackerRecordStore.countDaysCompleted(for: tracker.id)
            editIrregularTrackerVC.daysLabel.text = "\(numberOfDaysCompleted.formatDays())"
            print("\(numberOfDaysCompleted.formatDays())")
            
            editIrregularTrackerVC.setCompletionHandler { [weak self] editedTracker, categoryTitle in
                guard let self = self else { return }
                print("Вызов completionHandler перед созданием трекера")
                self.updateTracker(tracker, toCategoryTitle: categoryTitle)
                print("completionHandler вызван успешно")
            }
            
            let navController = UINavigationController(rootViewController: editIrregularTrackerVC)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    
    func formatDays(_ days: Set<WeekDay>) -> String {
        let sortedDays = days.sorted { $0.rawValue < $1.rawValue }
        if sortedDays.count == WeekDay.allCases.count {
            return "Каждый день"
        }
        return sortedDays.map { $0.shortName }.joined(separator: ", ")
    }
    
    func didPushDelete(_ tracker: Tracker) {
        let alertController = UIAlertController(
            title: "Уверены что хотите удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            do {
                try self.trackerStore.deleteTracker(withId: tracker.id)
                
                self.originalCategories[tracker.id] = nil
                
                self.loadCategories()
                self.updateUIForTrackers()
                
            } catch {
                print("Ошибка при удалении трекера: \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = .any
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveCompletedTrackers() {
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
        completedTrackers = Set(trackerRecordStore.trackerRecords)
        print("Загружено из CoreData: \(completedTrackers)")
    }
    
    private func loadPinnedTrackers() {
        let pinnedTrackers = trackerStore.pinnedTrackers(title: "pinned".localized())
        print("Загруженные закрепленные трекеры: \(pinnedTrackers)")
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


extension TrackersViewController: FilterSelectionDelegate {
    
    func didSelectFilter(_ filter: String?) {
        applyFilter(filter)
    }
    
    private func applyFilter(_ filter: String?) {
        currentFilter = filter
        displayedTrackers = trackers.filter { shouldDisplayTracker($0, on: currentDate) }
        updateUIForTrackers()
    }
}
