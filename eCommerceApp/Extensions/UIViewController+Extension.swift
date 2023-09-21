//
//  UIViewController+Extension.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

extension UIViewController {
    static var classIdentifier: String {
        return String(describing: self)
    }
}
