//
//  UITableView+Extension.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type) where T: Reusable & NibLoadable {
        register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func register<T: UITableViewCell>(cellType: T.Type) where T: Reusable {
        register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath,
                                                 cellType: T.Type = T.self) -> T where T: Reusable {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
                + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                + "and that you registered the cell beforehand")
        }
        
        return cell
    }
    
    func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) where T: Reusable & NibLoadable {
        register(headerFooterViewType.nib, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
    }
    
    func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) where T: Reusable {
        register(headerFooterViewType.self, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type = T.self) -> T? where T: Reusable {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T? else {
            fatalError(
                "Failed to dequeue a header/footer with identifier \(viewType.reuseIdentifier) "
                + "matching type \(viewType.self). "
                + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                + "and that you registered the header/footer beforehand")
        }
        
        return view
    }
}
