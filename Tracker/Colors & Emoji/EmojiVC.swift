//
//  EmojiVC.swift
//  Tracker
//
//  Created by Anton Demidenko on 10.9.24..
//

import Foundation
import UIKit

final class EmojiViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    weak var newUsualVC: NewUsualTrackerViewController?
    weak var newIrregularVC: NewIrregularTrackerViewController?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 2.5
        layout.sectionInset = UIEdgeInsets(top: 24, left: 6, bottom: 16, right: 6)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    var selectedEmoji: String?
    private var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView.isScrollEnabled = false
    }

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCollectionViewCell else {
            fatalError("Could not dequeue cell of type EmojiCollectionViewCell")
        }
        let emoji = emojis[indexPath.item]
        cell.configure(with: emoji)
        return cell
    }
    
    // MARK: - SectionHeader
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? SectionHeaderView else {
                fatalError("Could not dequeue header view")
            }
            headerView.configure(with: "Emoji")
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndexPath = selectedIndexPath {
            collectionView.deselectItem(at: selectedIndexPath, animated: false)
            if let oldCell = collectionView.cellForItem(at: selectedIndexPath) as? EmojiCollectionViewCell {
                oldCell.updateAppearance(isSelected: false)
            }
        }
        
        selectedIndexPath = indexPath
        selectedEmoji = emojis[indexPath.item]
        print("Selected emoji: \(selectedEmoji ?? "")")
        newUsualVC?.updateCreateButtonState()
        newIrregularVC?.updateCreateButtonState()
        
        if let newCell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
            newCell.updateAppearance(isSelected: true)
        }
    }
}
