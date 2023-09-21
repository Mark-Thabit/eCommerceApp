//
//  CartCell.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

class CartCell: UITableViewCell, NibReusable {
    
    // MARK: - IBOutlets
    
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    @IBOutlet var quantityLbl: UILabel!
    
    // MARK: - View life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        
    }
    
    // MARK: - Target actions
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        
    }
}
