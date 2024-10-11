//
//  OnboardingVC.swift
//  Tracker
//
//  Created by Anton Demidenko on 7.10.24..
//

import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    lazy var pages: [UIViewController] = {
        let firstView = createViewController(
            imageName: "Onboarding1",
            labelText: "Отслеживайте только\nто, что хотите",
            buttonTitle: "Вот это технологии!")
        
        let secondView = createViewController(
            imageName: "Onboarding2",
            labelText: "Даже если это\nне литры воды и йога",
            buttonTitle: "Вот это технологии!")
        
        return [firstView, secondView]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = UIColor(named: "YBlackColor")
        pageControl.pageIndicatorTintColor = UIColor(named: "YBlackColor")?.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        setupPageControl()
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createViewController(imageName: String, labelText: String, buttonTitle: String) -> UIViewController {
        let viewController = UIViewController()
        let backgroundImageView = UIImageView()
        let textLabel = UILabel()
        let button = UIButton()
        
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        textLabel.text = labelText
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        textLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YBlackColor")
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        viewController.view.addSubview(backgroundImageView)
        viewController.view.addSubview(button)
        viewController.view.addSubview(textLabel)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            button.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            textLabel.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor, constant: 64),
            textLabel.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16),
            
            backgroundImageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        return viewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            
            if let currentViewController = pageViewController.viewControllers?.first,
               let currentIndex = pages.firstIndex(of: currentViewController) {
                pageControl.currentPage = currentIndex
            }
        }
    @objc private func buttonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        let mainTabBarController = MainTabBarController()
        mainTabBarController.modalPresentationStyle = .fullScreen
        present(mainTabBarController, animated: true, completion: nil)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        return nextIndex == pages.count ? pages.first : pages[nextIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        return previousIndex < 0 ? pages.last : pages[previousIndex]
    }
}
