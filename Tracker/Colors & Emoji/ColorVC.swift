//
//  ColorCollectionView.swift
//  Tracker
//
//  Created by Anton Demidenko on 10.9.24..
//

import UIKit

final class ColorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var trackerCreationVC: TrackerCreationViewController?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 2.5
        layout.sectionInset = UIEdgeInsets(top: 24, left: 6, bottom: 0, right: 6)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        applyBackgroundColor()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let colors: [UIColor] = AppColor.allCases.compactMap { $0.color }
    let colorNames: [String] = AppColor.allCases.map { $0.rawValue }
    
    var selectedColor: UIColor?
    var selectedColorName: String?
    
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    func setSelectedColor(_ color: UIColor?) {
        guard let validColor = color else {
            print("Ошибка: цвет равен nil")
            return
        }
        
        selectedColor = validColor
        if let index = colors.firstIndex(of: validColor) {
            let indexPath = IndexPath(item: index, section: 0)
            selectedIndexPath = indexPath
            
            collectionView.reloadData()
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
                cell.isSelected = true
                cell.updateAppearance()
            }
            
            selectedColorName = colorNames[index]
            print("Выбранный цвет: \(validColor), название: \(selectedColorName ?? "не задано")")
        } else {
            print("Цвет не найден в массиве colors: \(validColor)")
        }
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
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let color = colors[indexPath.item]
        cell.configure(with: color)
        
        cell.isSelected = (indexPath == selectedIndexPath)
        
        return cell
    }
    
    // MARK: - SectionHeader
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? SectionHeaderView else {
                return UICollectionReusableView()
            }
            headerView.configure(with: "Цвет")
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
            if let oldCell = collectionView.cellForItem(at: selectedIndexPath) as? ColorCollectionViewCell {
                oldCell.isSelected = false
                oldCell.updateAppearance()
            }
        }
        
        selectedIndexPath = indexPath
        selectedColor = colors[indexPath.item]
        selectedColorName = colorNames[indexPath.item]
        
        if let selectedColor = selectedColor, let selectedColorName = selectedColorName {
            print("Selected color: \(selectedColor), name: \(selectedColorName)")
        }
        trackerCreationVC?.selectedColor = selectedColor
        trackerCreationVC?.checkColorAndEmojiState()

        if let newCell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
            newCell.isSelected = true
            newCell.updateAppearance()
        }
    }
}
