//
//  CartCell.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

protocol CartCellDelegate: AnyObject {
    func cartCellDeleteTapped(_ cartCell: CartCell)
    func cartCell(_ cartCell: CartCell, userUpdateQuantity count: Int)
}

class CartCell: UITableViewCell, NibReusable {
    
    // MARK: - IBOutlets
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    @IBOutlet var quantityLbl: UILabel!
    @IBOutlet var decreaseButton: UIButton!
    
    // MARK: - iVars
    
    weak var delegate: CartCellDelegate!
    var cartItem: (product: Product, qty: Int)! { didSet { configureCell() } }
    private var itemCount = 0 {
        didSet {
            guard oldValue != itemCount else { return }
            quantityLbl.text = "\(itemCount)"
            delegate.cartCell(self, userUpdateQuantity: itemCount)
            decreaseButton.isEnabled = itemCount > 1
        }
    }
    
    // MARK: - View life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        quantityLbl.layer.cornerRadius = 15
        quantityLbl.clipsToBounds = true
        
        setupContainerViewStyle()
        setupFonts()
    }
    
    private func setupContainerViewStyle() {
        containerView.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
        containerView.layer.cornerRadius = 25
    }
    
    private func setupFonts() {
        titleLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLbl.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    private func configureCell() {
        let product = cartItem.product
        
        itemImageView.sd_setImage(with: URL(string: product.imagePath)) { image, error, _, _ in
            self.loadingView.stopAnimating()
        }
        
        titleLbl.text = product.title
        priceLbl.text = product.formattedCurrency
        itemCount = cartItem.qty
    }
    
    // MARK: - Target actions
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        delegate.cartCellDeleteTapped(self)
    }
    
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        itemCount -= 1
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        itemCount += 1
    }
}
