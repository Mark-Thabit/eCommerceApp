//
//  MainTabBarController.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarController()
    }
    
    // MARK: - Helper Methods
    
    private func setupTabBarController() {
        setViewControllers(initializeViewControllerList(), animated: true)
        selectedIndex = 0
        tabBar.tintColor = .black
    }
    
    private func initializeViewControllerList() -> [UIViewController] {
        // Home
        let homeNavController = UINavigationController(rootViewController: HomeVC.instance)
        homeNavController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        // Cart
        let cartNavController = UINavigationController(rootViewController: CartVC.instance)
        cartNavController.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), selectedImage: UIImage(systemName: "cart.fill"))
        
        return [homeNavController, cartNavController]
    }
}
