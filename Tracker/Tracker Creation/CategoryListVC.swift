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

final class CategoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewCategoryViewControllerDelegate {
    private let trackerCategoryStore = TrackerCategoryStore()
    weak var delegate: CategorySelectionDelegate?
    
    private var categories: [String] = [] {
        didSet {
            trackerCategoryStore.saveCategories()
        }
    }
    
    var selectedCategory: String? {
        didSet {
            trackerCategoryStore.updateSelectedCategory(with: selectedCategory)
        }
    }
    
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
        imageView.isHidden = false
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
        
        if let savedCategories = try? trackerCategoryStore.fetchCategories() {
            categories = savedCategories.map { $0.title }
        }
        
        if let savedSelectedCategory = try? trackerCategoryStore.loadSelectedCategory() {
            selectedCategory = savedSelectedCategory.title
        }
        
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        view.addSubview(newCategoryButton)
        setupLayout()
        setupTableView()
        updateUI()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let categoryToSend = selectedCategory ?? nil
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
    
    private func updateUI() {
        let hasCategories = !categories.isEmpty
        stubImageView.isHidden = hasCategories
        stubLabel.isHidden = hasCategories
        tableView.isHidden = !hasCategories
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        let category = categories[indexPath.row]
        
        cell.textLabel?.text = category
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "TableViewColor")
        
        if selectedCategory == category {
            cell.accessoryType = .checkmark
            cell.separatorTrailingConstraint?.constant = 28
        } else {
            cell.separatorTrailingConstraint?.constant = -16
        }
        
        if categories.count > 1 {
            let isLastRow = indexPath.row == categories.count - 1
            cell.setSeparatorHidden(isLastRow)
        } else {
            cell.setSeparatorHidden(true)
        }
        
        if categories.count == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.masksToBounds = true
        } else if indexPath.row == categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        } else {
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        
        if self.selectedCategory == selectedCategory {
            self.selectedCategory = nil
        } else {
            self.selectedCategory = selectedCategory
        }
        
        tableView.reloadData()
        
        if let selectedCategory = self.selectedCategory {
            delegate?.didSelectCategory(selectedCategory)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func didAddCategory(_ category: String) {
        let newCategory = TrackerCategory(title: category, trackers: [])
        
        do {
            try trackerCategoryStore.addNewCategory(newCategory)
            categories.append(category)
            tableView.reloadData()
            updateUI()
        } catch {
            print("Ошибка при добавлении категории: \(error)")
        }
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let categoryToDelete = categories[indexPath.row]
                
                let alert = UIAlertController(title: "Удалить категорию?", message: "Вы уверены, что хотите удалить категорию '\(categoryToDelete)'?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
                    self?.deleteCategory(at: indexPath)
                }))
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        let categoryToDelete = categories[indexPath.row]
        
        do {
            try trackerCategoryStore.deleteCategory(withTitle: categoryToDelete)
        } catch {
            print("Ошибка при удалении категории: \(error)")
            return
        }
        
        
        categories.remove(at: indexPath.row)
        
        if selectedCategory == categoryToDelete {
            selectedCategory = nil
        }
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .fade)
        }, completion: { [weak self] _ in
            self?.updateUI()
        })
    }
    
    @objc private func newCategory(_ sender: UIButton) {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        let navController = UINavigationController(rootViewController: newCategoryVC)
        present(navController, animated: true, completion: nil)
    }
}
