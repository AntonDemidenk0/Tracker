//
//  CategoryListVC.swift
//  Tracker
//
//  Created by Anton Demidenko on 13.9.24..
//

import Foundation
import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: String?)
}

final class CategoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let viewModel = CategoryListViewModel()
    weak var delegate: CategorySelectionDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "MainScreenStub"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "YBlackColor")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var newCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = UIColor(named: "YBlackColor")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(newCategory), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Категория"
        view.backgroundColor = .white
        
        viewModel.onCategoriesUpdated = { [weak self] in
            self?.updateUI()
        }
        
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        view.addSubview(newCategoryButton)
        viewModel.loadCategories()
        setupLayout()
        setupTableView()
        updateUI()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !viewModel.isSelectedCategoryValid() {
            viewModel.selectedCategory = nil
        }
        
        let categoryToSend = viewModel.selectedCategory
        delegate?.didSelectCategory(categoryToSend)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            stubImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -60),
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: newCategoryButton.topAnchor, constant: -16)
        ])
    }
}

// MARK: - UI Updates
extension CategoryListViewController {
    
    func updateUI() {
        let hasCategories = !viewModel.categories.isEmpty
        stubImageView.isHidden = hasCategories
        stubLabel.isHidden = hasCategories
        tableView.isHidden = !hasCategories
        
        if hasCategories {
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard viewModel.categories.indices.contains(indexPath.row) else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.categories[indexPath.row]
        
        cell.textLabel?.text = category.title
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "TableViewColor")
        
        if viewModel.selectedCategory == category.title {
            cell.accessoryType = .checkmark
            cell.separatorTrailingConstraint?.constant = 28
        } else {
            cell.separatorTrailingConstraint?.constant = -16
        }
        
        if viewModel.categories.count > 1 {
            let isLastRow = indexPath.row == viewModel.categories.count - 1
            cell.setSeparatorHidden(isLastRow)
        } else {
            cell.setSeparatorHidden(true)
        }
        
        if viewModel.categories.count == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.masksToBounds = true
        } else if indexPath.row == viewModel.categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        } else {
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = viewModel.categories[indexPath.row]
        
        if viewModel.selectedCategory == selectedCategory.title {
            viewModel.selectedCategory = nil
            viewModel.updateSelectedCategory(with: nil)
        } else {
            viewModel.selectedCategory = selectedCategory.title
            viewModel.updateSelectedCategory(with: selectedCategory.title)
        }
        
        tableView.reloadData()
        
        if let selectedCategory =  viewModel.selectedCategory {
            delegate?.didSelectCategory(selectedCategory)
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Business Logic
extension CategoryListViewController {
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let categoryToDelete =  viewModel.categories[indexPath.row]
                
                let alert = UIAlertController(title: "Удалить категорию?", message: "Вы уверены, что хотите удалить категорию '\(categoryToDelete.title)'?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
                    self?.viewModel.deleteCategory(at: indexPath)
                }))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func newCategory() {
        let newCategoryVC = NewCategoryViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: newCategoryVC)
        present(navController, animated: true, completion: nil)
    }
}
