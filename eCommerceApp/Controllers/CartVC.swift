//
//  CartVC.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

class CartVC: UIViewController, Instantiatable {

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - StoryboardBasedView

extension CartVC: StoryboardBasedView {
    static var storyboard: UIStoryboard { .main }
}
