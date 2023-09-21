//
//  HomeVC.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

class HomeVC: UIViewController, Instantiatable {
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - StoryboardBasedView

extension HomeVC: StoryboardBasedView {
    static var storyboard: UIStoryboard { .main }
}
