//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Anton Demidenko on 14.10.24..
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    private let imageName: String
    private let labelText: String
    private let buttonTitle: String
    
    private let backgroundImageView = UIImageView()
    private let textLabel = UILabel()
    private let actionButton = UIButton()
    
    init(imageName: String, labelText: String, buttonTitle: String) {
        self.imageName = imageName
        self.labelText = labelText
        self.buttonTitle = buttonTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        
        textLabel.text = labelText
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        textLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textLabel.textColor = UIColor(named: "AlwaysBlack")
        view.addSubview(textLabel)
        
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        actionButton.layer.cornerRadius = 16
        actionButton.backgroundColor = UIColor(named: "AlwaysBlack")
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 64),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        let mainTabBarController = MainTabBarController()
        mainTabBarController.modalPresentationStyle = .fullScreen
        present(mainTabBarController, animated: true, completion: nil)
    }
}
