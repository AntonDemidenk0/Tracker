//
//  ScheduleListVC.swift
//  Tracker
//
//  Created by Anton Demidenko on 14.9.24..
//

import Foundation
import UIKit

enum WeekDay: Int, CaseIterable, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var displayName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    init?(shortName: String) {
        switch shortName {
        case "Пн": self = .monday
        case "Вт": self = .tuesday
        case "Ср": self = .wednesday
        case "Чт": self = .thursday
        case "Пт": self = .friday
        case "Сб": self = .saturday
        case "Вс": self = .sunday
        default: return nil
        }
    }
}

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectDays(_ days: String)
}

final class ScheduleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: ScheduleSelectionDelegate?
    
    private var tableView: UITableView!
    private var readyButton: UIButton!
    
    private var allDays: [WeekDay] {
        return WeekDay.allCases.sorted { $0.rawValue < $1.rawValue }
    }

    var selectedDays: Set<WeekDay> = [] {
        didSet {
            let daysRawValues = selectedDays.map { $0.rawValue }
            UserDefaults.standard.set(daysRawValues, forKey: "SelectedDays")
        }
    }

    var selectedDaysString: String {
        if selectedDays == Set(allDays) {
            return "Каждый день"
        } else {
            return allDays.filter { selectedDays.contains($0) }
                .map { $0.shortName }
                .joined(separator: ", ")
        }
    }

    private func setupReadyButton() {
        readyButton = UIButton(type: .system)
        readyButton.setTitle("Готово", for: .normal)
        readyButton.backgroundColor = UIColor(named: "YBlackColor")
        readyButton.setTitleColor(.white, for: .normal)
        readyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        readyButton.layer.cornerRadius = 16
        readyButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        
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
        navigationItem.title = "Расписание"
        setupTableView()
        setupReadyButton()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "dayCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! ScheduleTableViewCell
        let day = WeekDay.allCases[indexPath.row]
        
        let isSwitchOn = selectedDays.contains(day)
        cell.configure(with: day.displayName, isSwitchOn: isSwitchOn, separatorHidden: indexPath.row == WeekDay.allCases.count - 1)
        
        cell.switchControl.tag = indexPath.row
        cell.switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc func addSchedule(_ sender: UIButton) {
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

