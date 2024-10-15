//
//  ScheduleListVC.swift
//  Tracker
//
//  Created by Anton Demidenko on 14.9.24..
//

import Foundation
import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectDays(_ days: String)
}

final class ScheduleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: ScheduleSelectionDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "dayCell")
        return tableView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ready".localized(), for: .normal)
        button.backgroundColor = UIColor(named: "YBlackColor")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var didPressReadyButton = false
    private var allDays: [WeekDay] {
        return WeekDay.allCases.sorted { $0.rawValue < $1.rawValue }
    }
    
    private var selectedDays: Set<WeekDay> = [] {
        didSet {
            let daysRawValues = selectedDays.map { $0.rawValue }
            UserDefaults.standard.set(daysRawValues, forKey: "SelectedDays")
        }
    }
    
    private var selectedDaysString: String {
        if selectedDays == Set(allDays) {
            return "everyDay".localized()
        } else {
            return allDays.filter { selectedDays.contains($0) }
                .map { $0.shortName }
                .joined(separator: ", ")
        }
    }
    
    private func setupReadyButton() {
        view.addSubview(readyButton)
        
        NSLayoutConstraint.activate([
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "schedule".localized()
        setupTableView()
        setupReadyButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !didPressReadyButton {
            delegate?.didSelectDays("")
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as? ScheduleTableViewCell else {
            return UITableViewCell()
        }
        let day = WeekDay.allCases[indexPath.row]
        
        let isSwitchOn = selectedDays.contains(day)
        cell.configure(with: day.displayName, isSwitchOn: isSwitchOn, separatorHidden: indexPath.row == WeekDay.allCases.count - 1)
        
        cell.switchControl.tag = indexPath.row
        cell.switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc private func addSchedule(_ sender: UIButton) {
        if selectedDays.count == WeekDay.allCases.count {
            selectedDays = Set(WeekDay.allCases)
        }
        
        let selectedDaysString = selectedDays.sorted { $0.rawValue < $1.rawValue }
            .map { $0.shortName }
            .joined(separator: ", ")
        
        let selectedDaysRawValues = selectedDays.sorted { $0.rawValue < $1.rawValue }
            .map { $0.rawValue }
        UserDefaults.standard.set(selectedDaysRawValues, forKey: "SelectedDays")
        
        delegate?.didSelectDays(selectedDaysString)
        didPressReadyButton = true
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}
