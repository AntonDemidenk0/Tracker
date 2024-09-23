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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новая категория"
        view.backgroundColor = .white
        view.addSubview(categoryNameTextField)
        view.addSubview(readyButton)
        setupLayout()
        categoryNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
        ])
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            readyButton.isEnabled = true
            readyButton.backgroundColor = UIColor(named: "YBlackColor")
        } else {
            readyButton.isEnabled = false
            readyButton.backgroundColor = UIColor(named: "YGrayColor")
        }
    }
    
    @objc func addCategory(_ sender: UIButton) {
        if let categoryName = categoryNameTextField.text, !categoryName.isEmpty {
            delegate?.didAddCategory(categoryName)
            dismiss(animated: true, completion: nil)
        }
    }
}

