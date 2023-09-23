//
//  ProductDetailsVC.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import UIKit

class ProductDetailsVC: UIViewController, Instantiatable {
    
    // MARK: - IBOutlets
    
    @IBOutlet var categoryLbl: UILabel!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var ratingLbl: UILabel!
    @IBOutlet var ratingCountLbl: UILabel!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var priceLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var quantityLbl: UILabel!
    @IBOutlet var decreaseButton: UIButton!
    
    // MARK: - iVars
    
    var product: Product!
    private var quantity = 1 { 
        didSet {
            quantityLbl.text = "\(quantity)"
            decreaseButton.isEnabled = quantity > 1
        }
    }
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        populateUIWithProductInfo()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        ratingLbl.layer.cornerRadius = 10
        ratingLbl.clipsToBounds = true
        
        quantityLbl.layer.cornerRadius = 20
        quantityLbl.clipsToBounds = true
        
        setupFonts()
        setupNavigationStyle()
    }
    
    private func setupFonts() {
        categoryLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLbl.font = .systemFont(ofSize: 22, weight: .bold)
        ratingLbl.font = .systemFont(ofSize: 12, weight: .bold)
        ratingCountLbl.font = .systemFont(ofSize: 11, weight: .regular)
        priceLbl.font = .systemFont(ofSize: 25, weight: .heavy)
        descriptionLbl.font = .systemFont(ofSize: 14)
    }
    
    private func setupNavigationStyle() {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func populateUIWithProductInfo() {
        categoryLbl.text = product.category.capitalized
        titleLbl.text = product.title
        ratingLbl.text = "\(product.rating.rate) ★"
        ratingCountLbl.text = "(\(product.rating.count))"
        productImageView.sd_setImage(with: URL(string: product.imagePath))
        priceLbl.text = product.price.asFormattedCurrency
        descriptionLbl.text = product.desc
        quantity = 1
    }
    
    // MARK: - Target Actions
    
    @IBAction func decreaseButtonTapped(_ sender: UIButton) {
        quantity = max(1, quantity - 1)
    }
    
    @IBAction func increaseButtonTapped(_ sender: UIButton) {
        quantity += 1
    }
    
    @IBAction func addToCartButtonTapped(_ sender: UIButton) {
        Cart.current.addItem(with: product.id, qty: quantity)
    }
}

// MARK: - StoryboardBasedView

extension ProductDetailsVC: StoryboardBasedView {
    static var storyboard: UIStoryboard { .main }
}
