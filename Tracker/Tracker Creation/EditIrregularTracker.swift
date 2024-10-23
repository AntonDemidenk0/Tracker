//
//  EditIrregularTracker.swift
//  Tracker
//
//  Created by Anton Demidenko on 19.10.24..
//

import UIKit

final class EditIrregularTrackerViewController: TrackerCreationViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CategorySelectionDelegate {
    
    // MARK: - Properties
    private let trackerStore = TrackerStore.shared
    var selectedCategory: String?
    var selectedDaysString: String = "" {
        didSet {
            tableView.reloadData()
        }
    }
    var trackersViewController: TrackersViewController?
    var trackerName: String?
    var trackerId: UUID?
    
    lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textColor = UIColor(named: "YBlackColor") ?? .black
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var completionHandler: ((Tracker, String) -> Void)?
    
    func setCompletionHandler(_ handler: @escaping (Tracker, String) -> Void) {
        self.completionHandler = handler
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "editTracker.title".localized()
        tableView.dataSource = self
        tableView.delegate = self
        setupButtonActions()
        setupInitialSelection()
        adjustConstraits()
        setupDaysLabel()
        checkCreateButtonState()
        createButton.setTitle("save".localized(), for: .normal)
        trackerNameTextField.delegate = self
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addGestureRecognizer(tapGesture)
    }
    
    private func checkCreateButtonState() {
            let isTrackerNameValid = trackerName != nil
            let isCategorySelected = selectedCategory != nil
            
            let isAdditionalValidationsPassed = isTrackerNameValid && isCategorySelected
            checkColorAndEmojiState()
            
            updateCreateButtonState(isAdditionalValidationsPassed: isAdditionalValidationsPassed)
        }
    
    private func setupDaysLabel() {
        contentView.addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            daysLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            daysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
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
    
    @objc private func categoryListVC() {
        let categoryListVC = CategoryListViewController()
        categoryListVC.delegate = self
        let navController = UINavigationController(rootViewController: categoryListVC)
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
            checkCreateButtonState()
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
        checkCreateButtonState()
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
    
    private func adjustConstraits() {

        if let heightConstraint = contentView.constraints.first(where: { $0.firstAttribute == .height }) {
            contentView.removeConstraint(heightConstraint)
        }
        
        contentView.heightAnchor.constraint(equalToConstant: 853).isActive = true

        if let topConstraint = contentView.constraints.first(where: {
            $0.firstItem === trackerNameTextField && $0.firstAttribute == .top
        }) {
            contentView.removeConstraint(topConstraint)
        }
        
        trackerNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 102).isActive = true
        
        if let heightConstraint = tableView.constraints.first(where: { $0.firstAttribute == .height }) {
                tableView.removeConstraint(heightConstraint)
            }
        
            tableView.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    // MARK: - Actions
    
    private func setupButtonActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        trackerName = nil
        dismiss(animated: true, completion: nil)
        }
    
    @objc private func saveButtonTapped() {
        guard let trackerName = trackerNameTextField.text, !trackerName.isEmpty else {
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

        guard let trackerId = trackerId else {
            print("ID трекера не найден")
            return
        }
        
        let editedTracker = Tracker(
            id: trackerId,
            name: trackerName,
            color: selectedColorName,
            emoji: selectedEmoji,
            schedule: nil
        )
        guard let categoryTitle = selectedCategory else {
            print("Категория не выбрана")
            return
        }

        do {
            try trackerStore.deleteTracker(withId: trackerId)
            try trackerStore.addTracker(editedTracker, to: categoryTitle)
        } catch {
            print("Не удалось обработать трекер: \(error)")
        }
        completionHandler?(editedTracker, categoryTitle)

        dismiss(animated: true, completion: nil)
    }

}
