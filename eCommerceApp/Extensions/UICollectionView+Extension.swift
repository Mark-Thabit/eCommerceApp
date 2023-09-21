//
//  UICollectionView+Extension.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) where T: Reusable & NibLoadable {
        register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func register<T: UICollectionViewCell>(cellType: T.Type) where T: Reusable {
        register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T where T: Reusable {
        let bareCell = dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
        guard let cell = bareCell as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
                + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                + "and that you registered the cell beforehand")
        }
        
        return cell
    }
    
    func register<T: UICollectionReusableView>(supplementaryViewType: T.Type,
                                               ofKind elementKind: String) where T: Reusable & NibLoadable {
        register(supplementaryViewType.nib,
                 forSupplementaryViewOfKind: elementKind,
                 withReuseIdentifier: supplementaryViewType.reuseIdentifier)
    }
    
    func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) where T: Reusable {
        register(supplementaryViewType.self,
                 forSupplementaryViewOfKind: elementKind,
                 withReuseIdentifier: supplementaryViewType.reuseIdentifier)
    }
    
    final func dequeueReusableSupplementaryView<T: UICollectionReusableView> (ofKind elementKind: String,
                                                                              for indexPath: IndexPath,
                                                                              viewType: T.Type = T.self) -> T where T: Reusable {
        let view = dequeueReusableSupplementaryView(ofKind: elementKind,
                                                    withReuseIdentifier: viewType.reuseIdentifier,
                                                    for: indexPath)
        guard let typedView = view as? T else {
            fatalError(
                "Failed to dequeue a supplementary view with identifier \(viewType.reuseIdentifier) "
                + "matching type \(viewType.self). "
                + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                + "and that you registered the supplementary view beforehand")
        }
        
        return typedView
    }
}
