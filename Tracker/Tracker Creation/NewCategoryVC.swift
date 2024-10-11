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
    
    var viewModel: CategoryListViewModel
    
    init(viewModel: CategoryListViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    
    private lazy var categoryNameTextField: PaddedTextField = {
        let textField = PaddedTextField()
        textField.placeholder = "Введите название категории"
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "TableViewColor")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private lazy var readyButton: UIButton = {
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
    
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = UIColor(named: "CancelButtonColor")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая категория"
        view.backgroundColor = .white
        view.addSubview(categoryNameTextField)
        view.addSubview(readyButton)
        view.addSubview(limitLabel)
        
        setupLayout()
        
        categoryNameTextField.delegate = self
        categoryNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
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
            
            limitLabel.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
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
    
    private func showLimitLabel() {
        limitLabel.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.limitLabel.alpha = 1
        }
    }
    
    private func hideLimitLabel() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.limitLabel.alpha = 0
        } completion: { [weak self] _ in
            self?.limitLabel.isHidden = true
        }
    }
    
    @objc private func addCategory(_ sender: UIButton) {
        if let categoryName = categoryNameTextField.text, !categoryName.isEmpty {
            viewModel.didAddCategory(categoryName)
            dismiss(animated: true, completion: nil)
        }
    }
}
