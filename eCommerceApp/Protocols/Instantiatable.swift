//
//  Instantiatable.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

protocol Instantiatable {
    static var instance: UIViewController { get }
}

extension Instantiatable where Self: UIViewController & StoryboardBasedView {
    static var instance: UIViewController {
        return storyboard.instantiateViewController(identifier: classIdentifier)
    }
}
