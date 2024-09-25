//
//  NewCategoryVC.swift
//  Tracker
//
//  Created by Anton Demidenko on 13.9.24..
//

import Foundation
import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didAddCategory(_ category: String)
}

final class NewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    private let categoryNameTextField: PaddedTextField = {
        let textField = PaddedTextField()
        textField.placeholder = "Введите название категории"
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "TableViewColor")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = UIColor(named: "YGrayColor")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var limitLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая категория"
        view.backgroundColor = .white
        view.addSubview(categoryNameTextField)
        view.addSubview(readyButton)
        
        setupLayout()
        setupLimitLabel()
        
        categoryNameTextField.delegate = self
        
        categoryNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup UI
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
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
        
        view.addSubview(limitLabel)
        
        NSLayoutConstraint.activate([
            limitLabel.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 38 {
            showLimitLabel()
        } else {
            hideLimitLabel()
        }
        
        return updatedText.count <= 38
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == categoryNameTextField {
            print("Category name: \(textField.text ?? "")")
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        print("Text changed: \(textField.text ?? "")")
        
        if let text = textField.text, !text.isEmpty {
            readyButton.isEnabled = true
            readyButton.backgroundColor = UIColor(named: "YBlackColor")
            
            if text.count > 38 {
                showLimitLabel()
            } else {
                hideLimitLabel()
            }
            
        } else {
            readyButton.isEnabled = false
            readyButton.backgroundColor = UIColor(named: "YGrayColor")
            hideLimitLabel()
        }
    }

    // MARK: - Limit Label Actions
    
    private func showLimitLabel() {
        limitLabel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.limitLabel.alpha = 1
        }
    }
    
    private func hideLimitLabel() {
        UIView.animate(withDuration: 0.3) {
            self.limitLabel.alpha = 0
        } completion: { _ in
            self.limitLabel.isHidden = true
        }
    }

    @objc func addCategory(_ sender: UIButton) {
        if let categoryName = categoryNameTextField.text, !categoryName.isEmpty {
            delegate?.didAddCategory(categoryName)
            dismiss(animated: true, completion: nil)
        }
    }
}
