//
//  Filters.swift
//  Tracker
//
//  Created by Anton Demidenko on 23.10.24..
//

import Foundation
import UIKit

protocol FilterSelectionDelegate: AnyObject {
    func didSelectFilter(_ filter: String?)
}

final class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: FilterSelectionDelegate?

    private let filters = [
        "all_trackers".localized(),
        "trackers_today".localized(),
        "completed".localized(),
        "not_completed".localized()
    ]
    private var selectedFilter: String? {
        didSet {
            UserDefaults.standard.set(selectedFilter, forKey: "selectedFilter")
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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("filters", comment: "Title for the filter button")
        applyBackgroundColor()
        setupTableView()
        loadSelectedFilter()
    }

    private func loadSelectedFilter() {
        selectedFilter = UserDefaults.standard.string(forKey: "selectedFilter")
    }

    private func setupTableView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CustomTableViewCell
        cell.textLabel?.text = filters[indexPath.row]
        cell.selectionStyle = .none
        
        if filters[indexPath.row] == selectedFilter {
            cell.accessoryType = .checkmark
            cell.separatorTrailingConstraint?.constant = 28
        } else {
            cell.accessoryType = .none
            cell.separatorTrailingConstraint?.constant = -16
        }

        let isLastRow = indexPath.row == filters.count - 1
        cell.setSeparatorHidden(isLastRow)

        if filters.count == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastRow {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = filters[indexPath.row]

        if selectedFilter == selected {
            selectedFilter = nil
        } else {
            selectedFilter = selected
        }
        
        delegate?.didSelectFilter(selectedFilter)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
