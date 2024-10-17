//
//  NewIrregularTrackerViewController.swift
//  Tracker
//
//  Created by Anton Demidenko on 22.9.24..
//

import Foundation
import UIKit

final class NewIrregularTrackerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CategorySelectionDelegate {
    
    // MARK: - Properties
    private var selectedCategory: String?
    var trackersViewController: TrackersViewController?
    var selectedColor: UIColor?
    var selectedEmoji: String?
    private var trackerName: String?
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        return tableView
    }()
    private lazy var colorVC: ColorViewController = {
        let vc = ColorViewController()
        vc.newIrregularVC = self
        return vc
    }()
    private lazy var emojiVC: EmojiViewController = {
        let vc = EmojiViewController()
        vc.newIrregularVC = self
        return vc
    }()
    private lazy var trackerNameTextField: PaddedTextField = {
        let textField = PaddedTextField()
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.placeholder = "trackerNameTextFieldPlaceholder.title".localized()
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "TableViewColor")
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = "limitLabelText".localized()
        label.textColor = UIColor(named: "CancelButtonColor")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        label.isHidden = true
        return label
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("cancel".localized(), for: .normal)
        button.setTitleColor(UIColor(named: "CancelButtonColor"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.borderColor = UIColor(named: "CancelButtonColor")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("create".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = UIColor(named: "YGrayColor")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var completionHandler: ((Tracker, String) -> Void)?
    private var closeNewTrackerVCHandler: (() -> Void)?

    func setCompletionHandler(_ handler: @escaping (Tracker, String) -> Void) {
        self.completionHandler = handler
    }

    func setCloseNewTrackerVCHandler(_ handler: @escaping () -> Void) {
        self.closeNewTrackerVCHandler = handler
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "newIrregularTrackerNavItem.title".localized()
        applyBackgroundColor()

        setupScrollView()
        setupTextField()
        setupTableView()
        setupChildViewControllers()
        setupButtons()
        setupLimitLabel()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    // MARK: - Setup UI

    private func setupButtons() {
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("cancel".localized(), for: .normal)
        cancelButton.setTitleColor(UIColor(named: "CancelButtonColor"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.layer.borderColor = UIColor(named: "CancelButtonColor")?.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 16
        cancelButton.backgroundColor = .clear
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        createButton = UIButton(type: .system)
        createButton.setTitle("create".localized(), for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createButton.backgroundColor = UIColor(named: "YGrayColor")
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.isEnabled = false
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
    }

    private func setupTextField() {
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
        contentView.addSubview(limitLabel)

        NSLayoutConstraint.activate([
            limitLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
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

            contentView.heightAnchor.constraint(equalToConstant: 775)
        ])
    }

    private func setupTableView() {
        contentView.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

    private func setupChildViewControllers() {
        addChild(colorVC)
        contentView.addSubview(colorVC.view)
        colorVC.didMove(toParent: self)

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
        let isColorSelected = colorVC.selectedColorName != nil
        let isEmojiSelected = emojiVC.selectedEmoji != nil

        createButton.isEnabled = isTrackerNameValid && isCategorySelected && isColorSelected && isEmojiSelected
        
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let buttonBackgroundColor = createButton.isEnabled ? UIColor(named: "YBlackColor") : UIColor(named: "YGrayColor")
        let buttonTextColor = createButton.isEnabled && isDarkMode ? UIColor(named: "TabBarBorderColor") : UIColor.white
        
        createButton.backgroundColor = buttonBackgroundColor
        createButton.setTitleColor(buttonTextColor, for: .normal)
    }

    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CustomTableViewCell else {
            fatalError("Unable to dequeue CustomTableViewCell")
        }
        let mainText = "category".localized()
        
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
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.setSeparatorHidden(true)
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryVC = CategoryListViewController()
        categoryVC.delegate = self
        let navVC = UINavigationController(rootViewController: categoryVC)
        navVC.modalPresentationStyle = .popover
        present(navVC, animated: true, completion: nil)
    }
    
    // MARK: - CategorySelectionDelegate
    
    func didSelectCategory(_ category: String?) {
        if let category = category {
            self.selectedCategory = category
        } else {
            self.selectedCategory = nil
        }
        updateCreateButtonState()
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
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
        
        let irregularTracker = Tracker(id: UUID(), name: trackerName, color: selectedColorName, emoji: selectedEmoji, schedule: nil)
        
        guard let categoryTitle = selectedCategory else {
            print("Категория не выбрана")
            return
        }
        
        completionHandler?(irregularTracker, categoryTitle)
        print("Completion handler called with tracker: \(irregularTracker) and category: \(categoryTitle)")
        
        dismiss(animated: true, completion: nil)
        
        closeNewTrackerVCHandler?()
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
}
