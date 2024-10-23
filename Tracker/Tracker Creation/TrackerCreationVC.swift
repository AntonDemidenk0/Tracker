//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Anton Demidenko on 21.10.24..
//

import UIKit

class TrackerCreationViewController: UIViewController {
    
    // MARK: - UI Components
    
    lazy var scrollView = UIScrollView()
    lazy var contentView = UIView()
    var selectedColor: UIColor?
    var selectedEmoji: String?
    lazy var trackerNameTextField: PaddedTextField = {
        let textField = PaddedTextField()
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.placeholder = "trackerNameTextFieldPlaceholder.title".localized()
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "TableViewColor")
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        return tableView
    }()
    lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = "limitLabelText".localized()
        label.textColor = UIColor(named: "CancelButtonColor")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.alpha = 0
        label.isHidden = true
        return label
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("cancel".localized(), for: .normal)
        button.setTitleColor(UIColor(named: "CancelButtonColor"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.borderColor = UIColor(named: "CancelButtonColor")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        return button
    }()
    lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("create".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = UIColor(named: "YGrayColor")
        button.layer.cornerRadius = 16
        return button
    }()
    lazy var colorVC = ColorViewController()
    lazy var emojiVC = EmojiViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup UI Components
    private func setupUI() {
        applyBackgroundColor()
        setupScrollView()
        setupTextField()
        setupTableView()
        setupChildViewControllers()
        setupButtons()
        setupLimitLabel()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
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

    private func setupTextField() {
        contentView.addSubview(trackerNameTextField)
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackerNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

    private func setupLimitLabel() {
        contentView.addSubview(limitLabel)
        limitLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            limitLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func setupButtons() {
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
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

    private func setupChildViewControllers() {
        colorVC.trackerCreationVC = self
            addChild(colorVC)
            contentView.addSubview(colorVC.view)
            colorVC.didMove(toParent: self)

            emojiVC.trackerCreationVC = self
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
    
    func setupInitialSelection() {
        colorVC.selectedColor = selectedColor
        guard let colorToSet = selectedColor else {
            print("Ошибка: selectedColor равен nil")
            return
        }
        colorVC.setSelectedColor(colorToSet)
        emojiVC.selectedEmoji = selectedEmoji
        emojiVC.setSelectedEmoji(selectedEmoji)
    }
    
    func checkColorAndEmojiState() {
            let isColorSelected = colorVC.selectedColorName != nil
            let isEmojiSelected = emojiVC.selectedEmoji != nil
            print("checkColorAndEmojiState вызывается")
            updateCreateButtonState(isAdditionalValidationsPassed: isColorSelected && isEmojiSelected)
        }
    
    func updateCreateButtonState(isAdditionalValidationsPassed: Bool) {
            let isColorSelected = colorVC.selectedColorName != nil
            let isEmojiSelected = emojiVC.selectedEmoji != nil

            createButton.isEnabled = isAdditionalValidationsPassed && isColorSelected && isEmojiSelected

            let isDarkMode = traitCollection.userInterfaceStyle == .dark
            let buttonBackgroundColor = createButton.isEnabled ? UIColor(named: "YBlackColor") : UIColor(named: "YGrayColor")
            let buttonTextColor = createButton.isEnabled && isDarkMode ? UIColor(named: "TabBarBorderColor") : UIColor.white

            createButton.backgroundColor = buttonBackgroundColor
            createButton.setTitleColor(buttonTextColor, for: .normal)
        }
}
