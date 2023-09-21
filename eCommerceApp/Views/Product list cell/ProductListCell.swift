//
//  ProductListCell.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

class ProductListCell: UICollectionViewCell, NibReusable {
    
    // MARK: - IBOutlets
    
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    
    // MARK: - View life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        loadingView.startAnimating()
        loadingView.hidesWhenStopped = true
    }
}
