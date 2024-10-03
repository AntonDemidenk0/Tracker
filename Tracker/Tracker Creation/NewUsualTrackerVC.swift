//
//  NewTrackerCreationVC.swift
//  Tracker
//
//  Created by Anton Demidenko on 10.9.24..
//

import UIKit

final class NewUsualTrackerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CategorySelectionDelegate, ScheduleSelectionDelegate {
    
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private var selectedCategory: String?
    private var selectedDaysString: String = "" {
        didSet {
            tableView.reloadData()
        }
    }
    var trackersViewController: TrackersViewController?
    var selectedColor: UIColor?
    var selectedEmoji: String?
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var tableView: UITableView!
    private var colorVC: ColorViewController!
    private var emojiVC: EmojiViewController!
    private var trackerNameTextField: PaddedTextField!
    private var trackerName: String?
    private var limitLabel: UILabel!
    
    private var cancelButton: UIButton!
    private var createButton: UIButton!
    
    private var completionHandler: ((Tracker, String) -> Void)?
    
    func setCompletionHandler(_ handler: @escaping (Tracker, String) -> Void) {
        self.completionHandler = handler
    }
    private var closeNewTrackerVCHandler: (() -> Void)?
    func setCloseNewTrackerVCHandler(_ handler: @escaping () -> Void) {
        self.closeNewTrackerVCHandler = handler
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая привычка"
        view.backgroundColor = .white
        
        setupScrollView()
        setupTextField()
        setupTableView()
        setupChildViewControllers()
        setupButtons()
        setupLimitLabel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup UI
    
    private func setupButtons() {
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(UIColor(named: "CancelButtonColor"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.layer.borderColor = UIColor(named: "CancelButtonColor")?.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 16
        cancelButton.backgroundColor = .clear
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton = UIButton(type: .system)
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createButton.backgroundColor = UIColor(named: "YGrayColor")
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
        updateCreateButtonState()
    }
    
    private func setupTextField() {
        trackerNameTextField = PaddedTextField()
        trackerNameTextField.font = UIFont.systemFont(ofSize: 17)
        trackerNameTextField.placeholder = "Введите название трекера"
        trackerNameTextField.layer.cornerRadius = 16
        trackerNameTextField.backgroundColor = UIColor(named: "TableViewColor")
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        trackerNameTextField.delegate = self
        trackerNameTextField.clearButtonMode = .whileEditing
        contentView.addSubview(trackerNameTextField)
        
        NSLayoutConstraint.activate([
            trackerNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
        ])
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupLimitLabel() {
        limitLabel = UILabel()
        limitLabel.text = "Ограничение 38 символов"
        limitLabel.textColor = UIColor(named: "CancelButtonColor")
        limitLabel.textAlignment = .center
        limitLabel.font = UIFont.systemFont(ofSize: 17)
        limitLabel.translatesAutoresizingMaskIntoConstraints = false
        limitLabel.alpha = 0
        limitLabel.isHidden = true
        
        contentView.addSubview(limitLabel)
        
        NSLayoutConstraint.activate([
            limitLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            contentView.heightAnchor.constraint(equalToConstant: 850)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupChildViewControllers() {
        colorVC = ColorViewController()
        colorVC.newUsualVC = self
        addChild(colorVC)
        contentView.addSubview(colorVC.view)
        colorVC.didMove(toParent: self)
        
        emojiVC = EmojiViewController()
        emojiVC.newUsualVC = self
        addChild(emojiVC)
        contentView.addSubview(emojiVC.view)
        emojiVC.didMove(toParent: self)
        
        colorVC.view.translatesAutoresizingMaskIntoConstraints = false
        emojiVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiVC.view.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiVC.view.heightAnchor.constraint(equalToConstant: 204),
            
            colorVC.view.topAnchor.constraint(equalTo: emojiVC.view.bottomAnchor, constant: 16),
            colorVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorVC.view.heightAnchor.constraint(equalToConstant: 204)
        ])
    }
    
    func updateCreateButtonState() {
        let isTrackerNameValid = trackerName != nil
        let isCategorySelected = selectedCategory != nil
        let isScheduleSelected = !(selectedDaysString.isEmpty)
        let isColorSelected = colorVC.selectedColorName != nil
        let isEmojiSelected = emojiVC.selectedEmoji != nil
        
        createButton.isEnabled = isTrackerNameValid && isCategorySelected && isScheduleSelected && isColorSelected && isEmojiSelected
        createButton.backgroundColor = createButton.isEnabled ? UIColor(named: "YBlackColor") : UIColor(named: "YGrayColor")
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CustomTableViewCell else {
            fatalError("Unable to dequeue CustomTableViewCell")
        }
        cell.configure(with: "Your Text", separatorHidden: false)
        cell.setAccessoryType(.disclosureIndicator)
        
        if indexPath.row == 0 {
            let mainText = "Категория"
            
            if let selectedCategory = selectedCategory {
                let combinedText = "\(mainText)\n\(selectedCategory)"
                let attributedText = NSMutableAttributedString(string: combinedText)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 2
                attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: combinedText.count))
                attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .regular), range: NSRange(location: 0, length: mainText.count))
                let secondLineRange = NSRange(location: mainText.count + 1, length: selectedCategory.count)
                attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .regular), range: secondLineRange)
                attributedText.addAttribute(.foregroundColor, value: UIColor(named: "YGrayColor") ?? UIColor.gray, range: secondLineRange)
                cell.titleLabel.attributedText = attributedText
            } else {
                cell.titleLabel.text = mainText
            }
            cell.setSeparatorHidden(false)
        } else if indexPath.row == 1 {
            
            let mainText = "Расписание"
            if !selectedDaysString.isEmpty {
                let combinedText = "\(mainText)\n\(selectedDaysString)"
                let attributedText = NSMutableAttributedString(string: combinedText)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 2
                attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: combinedText.count))
                attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .regular), range: NSRange(location: 0, length: mainText.count))
                let secondLineRange = NSRange(location: mainText.count + 1, length: selectedDaysString.count)
                attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .regular), range: secondLineRange)
                attributedText.addAttribute(.foregroundColor, value: UIColor(named: "YGrayColor") ?? UIColor.gray, range: secondLineRange)
                cell.titleLabel.attributedText = attributedText
            } else {
                
                cell.titleLabel.text = mainText
            }
            cell.setSeparatorHidden(true)
        }
        
        return cell
    }
    
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            categoryListVC()
        } else if indexPath.row == 1 {
            scheduleListVC()
        }
    }
    
    @objc private func categoryListVC() {
        let categoryListVC = CategoryListViewController()
        categoryListVC.delegate = self
        let navController = UINavigationController(rootViewController: categoryListVC)
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func scheduleListVC() {
        let scheduleListVC = ScheduleListViewController()
        scheduleListVC.delegate = self
        let navController = UINavigationController(rootViewController: scheduleListVC)
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 38
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == trackerNameTextField {
            trackerName = textField.text
            updateCreateButtonState()
            print("Tracker name: \(trackerName ?? "")")
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        print("Text changed: \(textField.text ?? "")")
        
        let isOverLimit = (textField.text?.count ?? 0) > 37
        limitLabel.isHidden = !isOverLimit
        updateContentViewHeight()
        
        if isOverLimit {
            UIView.animate(withDuration: 0.3, animations: {
                self.limitLabel.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.limitLabel.alpha = 0
            })
        }
    }
    
    func didSelectCategory(_ category: String?) {
        if let category = category {
            self.selectedCategory = category
        } else {
            self.selectedCategory = nil
        }
        updateCreateButtonState()
        tableView.reloadData()
    }
    
    func didSelectDays(_ days: String) {
        selectedDaysString = days
        
        let selectedDays = days.split(separator: ",").compactMap { WeekDay(shortName: $0.trimmingCharacters(in: .whitespaces)) }
        
        let sortedDays = WeekDay.allCases.sorted { $0.rawValue < $1.rawValue }
        let sortedSelectedDays = selectedDays.filter { sortedDays.contains($0) }
        
        let sortedDaysString = sortedSelectedDays.count == WeekDay.allCases.count ? "Каждый день" : sortedSelectedDays.map { $0.shortName }.joined(separator: ", ")
        
        self.selectedDaysString = sortedDaysString
        updateCreateButtonState()
        tableView.reloadData()
    }
    
    
    private func updateContentViewHeight() {
        let newTopConstraintConstant: CGFloat = limitLabel.isHidden ? 24 : 62
        
        if let tableViewTopConstraint = contentView.constraints.first(where: { $0.firstItem as? UIView == tableView && $0.firstAttribute == .top }) {
            
            if tableViewTopConstraint.constant != newTopConstraintConstant {
                tableViewTopConstraint.constant = newTopConstraintConstant
                
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                })
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        trackerName = nil
        if let handler = closeNewTrackerVCHandler {
            dismiss(animated: true, completion: nil)
            handler()
        }
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = trackerName, !trackerName.isEmpty else {
            print("Необходимо ввести название трекера")
            return
        }
        
        guard let selectedColorName = colorVC.selectedColorName else {
            print("Не выбран цвет")
            return
        }
        
        guard let selectedEmoji = emojiVC.selectedEmoji else {
            print("Не выбран эмодзи")
            return
        }
        
        let scheduleArray: [String]
        if selectedDaysString == "Каждый день" || selectedDaysString.isEmpty {
            scheduleArray = WeekDay.allCases.map { $0.shortName }
        } else {
            scheduleArray = selectedDaysString.components(separatedBy: ", ")
        }
        
        let scheduleSet: Set<WeekDay> = Set(scheduleArray.compactMap { WeekDay(shortName: $0.trimmingCharacters(in: .whitespaces)) })
        
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColorName,
            emoji: selectedEmoji,
            schedule: scheduleSet
        )
        
        guard let categoryTitle = selectedCategory else {
            print("Категория не выбрана")
            return
        }
        
        completionHandler?(newTracker, categoryTitle)
        print("Completion handler called with tracker: \(newTracker) and category: \(categoryTitle)")
        
        dismiss(animated: true, completion: nil)
        
        closeNewTrackerVCHandler?()
    }
}
