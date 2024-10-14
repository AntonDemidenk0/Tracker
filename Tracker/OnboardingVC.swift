//
//  OnboardingVC.swift
//  Tracker
//
//  Created by Anton Demidenko on 7.10.24..
//

import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    lazy var pages: [UIViewController] = {
        let firstView = OnboardingPageViewController(
            imageName: "Onboarding1",
            labelText: "Отслеживайте только\nто, что хотите",
            buttonTitle: "Вот это технологии!"
        )
        
        let secondView = OnboardingPageViewController(
            imageName: "Onboarding2",
            labelText: "Даже если это\nне литры воды и йога",
            buttonTitle: "Вот это технологии!"
        )
        
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
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool)
    {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        return pages[(viewControllerIndex + 1) % pages.count]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        return pages[(viewControllerIndex + pages.count - 1) % pages.count]
    }
}
