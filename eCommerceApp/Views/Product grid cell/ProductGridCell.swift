//
//  ProductGridCell.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

class ProductGridCell: UICollectionViewCell, NibReusable {
    
    // MARK: - IBOutlets
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    
    // MARK: - iVars
    
    var product: Product! {
        didSet {
            configureCell()
        }
    }
    
    // MARK: - View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        setupFonts()
        setupContainerViewStyle()
    }
    
    private func setupFonts() {
        titleLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLbl.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    private func setupContainerViewStyle() {
        containerView.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
        containerView.layer.cornerRadius = 25
    }
    
    private func configureCell() {
        titleLbl.text = product.title
        priceLbl.text = product.formattedCurrency
        productImageView.sd_setImage(with: URL(string: product.imagePath)) { image, error, _, _ in
            self.loadingView.stopAnimating()
        }
    }
}
