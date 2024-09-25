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
    
    // MARK: - Properties
    
    weak var delegate: CategorySelectionDelegate?
    
    private var categories: [String] = [] {
        didSet {
            UserDefaults.standard.set(categories, forKey: "SavedCategories")
        }
    }
    var selectedCategory: String? {
        didSet {
            UserDefaults.standard.set(selectedCategory, forKey: "SelectedCategory")
        }
    }
    
    private var tableView: UITableView!
    
    // MARK: - UI Elements
    
    private let stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "MainScreenStub"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = false
        return imageView
    }()
    
    private let stubLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "YBlackColor")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newCategoryButton: UIButton = {
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Категория"
        view.backgroundColor = .white
        
        if let savedCategories = UserDefaults.standard.array(forKey: "SavedCategories") as? [String] {
            categories = savedCategories
        }
        
        if let savedSelectedCategory = UserDefaults.standard.string(forKey: "SelectedCategory") {
            selectedCategory = savedSelectedCategory
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
    
    // MARK: - Setup UI
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: newCategoryButton.topAnchor, constant: -16)
        ])
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
    
    private func updateUI() {
        let hasCategories = !categories.isEmpty
        stubImageView.isHidden = hasCategories
        stubLabel.isHidden = hasCategories
        tableView.isHidden = !hasCategories
        
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource & Delegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CustomTableViewCell
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

    // MARK: - NewCategoryViewControllerDelegate
    
    func didAddCategory(_ category: String) {
        categories.append(category)
        tableView.reloadData()
        updateUI()
    }
    
    // MARK: - Long Press Gesture
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let categoryToDelete = categories[indexPath.row]
                
                let alert = UIAlertController(title: "Удалить категорию?", message: "Вы уверены, что хотите удалить категорию '\(categoryToDelete)'?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { _ in
                    self.deleteCategory(at: indexPath)
                }))
                
                present(alert, animated: true, completion: nil)
            }
        }
    }

    private func deleteCategory(at indexPath: IndexPath) {
        let categoryToDelete = categories[indexPath.row]
        
        categories.remove(at: indexPath.row)
        
        if selectedCategory == categoryToDelete {
            selectedCategory = nil
        }
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .fade)
        }, completion: { _ in
            self.updateUI()
        })
    }

    // MARK: - Actions
    
    @objc func newCategory(_ sender: UIButton) {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        let navController = UINavigationController(rootViewController: newCategoryVC)
        present(navController, animated: true, completion: nil)
    }
}
