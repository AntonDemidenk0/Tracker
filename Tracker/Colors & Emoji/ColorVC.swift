//
//  ColorCollectionView.swift
//  Tracker
//
//  Created by Anton Demidenko on 10.9.24..
//

import UIKit

class ColorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var collectionView: UICollectionView!
    
    private let colors: [UIColor] = [
        UIColor(named: "CRed")!,
        UIColor(named: "COrange")!,
        UIColor(named: "CBlue")!,
        UIColor(named: "CViolet")!,
        UIColor(named: "CGreen")!,
        UIColor(named: "CPink")!,
        UIColor(named: "CPigPink")!,
        UIColor(named: "CLightBlue")!,
        UIColor(named: "CSalad")!,
        UIColor(named: "CDarkViolet")!,
        UIColor(named: "CLightRed")!,
        UIColor(named: "CLightPink")!,
        UIColor(named: "CYellow")!,
        UIColor(named: "CPastelBlue")!,
        UIColor(named: "COneMoreViolet")!,
        UIColor(named: "CAnotherOneViolet")!,
        UIColor(named: "CVioletBlue")!,
        UIColor(named: "CBrightGreen")!
    ]
    
    private let colorNames: [String] = [
        "CRed", "COrange", "CBlue", "CViolet", "CGreen", "CPink", "CPigPink",
        "CLightBlue", "CSalad", "CDarkViolet", "CLightRed", "CLightPink",
        "CYellow", "CPastelBlue", "COneMoreViolet", "CAnotherOneViolet",
        "CVioletBlue", "CBrightGreen"
    ]
    
    var selectedColor: UIColor?
    var selectedColorName: String?
    
    
    private var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 2.5
        layout.sectionInset = UIEdgeInsets(top: 24, left: 6, bottom: 0, right: 6)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCollectionViewCell
        let color = colors[indexPath.item]
        cell.configure(with: color)
        
        
        if indexPath == selectedIndexPath {
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.black.cgColor
        } else {
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    // MARK: - SectionHeader
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
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
        print("Selected color: \(selectedColor!), name: \(selectedColorName!)")
        
        if let newCell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
            newCell.isSelected = true
            newCell.updateAppearance()
        }
    }
}