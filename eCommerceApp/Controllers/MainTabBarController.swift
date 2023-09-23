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
        homeNavController.navigationBar.tintColor = .black
        homeNavController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        // Cart
        let cartNavController = UINavigationController(rootViewController: CartVC.instance)
        cartNavController.navigationBar.tintColor = .black
        cartNavController.tabBarItem = UITabBarItem(title: "Cart", image: cartTabImage(isSelected: false), selectedImage: cartTabImage(isSelected: true))
        
        return [homeNavController, cartNavController]
    }
    
    private func cartTabImage(isSelected: Bool) -> UIImage? {
        let isCartEmpty = Cart.current.itemList.isEmpty
        let image: UIImage?
        
        if isCartEmpty {
            image = isSelected ? UIImage(systemName: "cart.fill") : UIImage(systemName: "cart")
        } else {
            image = isSelected ? UIImage(systemName: "cart.fill") : UIImage(systemName: "cart")
        }
        
        return image
    }
    
    private func updateCartTabImage() {
        viewControllers?.last?.tabBarItem = UITabBarItem(title: "Cart", image: cartTabImage(isSelected: false), selectedImage: cartTabImage(isSelected: true))
    }
}
