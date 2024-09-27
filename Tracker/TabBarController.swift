//
//  TabBarController.swift
//  Tracker
//
//  Created by Anton Demidenko on 19.9.24..
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let trackersVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()

        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "TrackerIcon"), tag: 0)
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "StatisticsIcon"), tag: 1)

        let trackersNavController = UINavigationController(rootViewController: trackersVC)
        let statisticsNavController = UINavigationController(rootViewController: statisticsVC)

        viewControllers = [trackersNavController, statisticsNavController]

        setupTabBarAppearance()
    }

    // MARK: - Setuo
    private func setupTabBarAppearance() {
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = false

        let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1))
        topBorder.backgroundColor = UIColor(named: "YGrayColor") ?? .gray
        tabBar.addSubview(topBorder)
    }
}



