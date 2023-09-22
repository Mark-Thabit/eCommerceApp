//
//  Product.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import Foundation

struct Product: Decodable {
    
    // MARK: - iVars
    
    let id: Int
    let title: String
    let imagePath: String
    let price: Double
    let desc: String
    let category: String
    
    // MARK: - Computed Properties
    
    var formattedCurrency: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: price as NSNumber)
    }
    
    // MARK: - Coding keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imagePath = "image"
        case price
        case desc = "description"
        case category
    }
    
    // MARK: - Initializers
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        imagePath = try container.decode(String.self, forKey: .imagePath)
        price = try container.decode(Double.self, forKey: .price)
        desc = try container.decode(String.self, forKey: .desc)
        category = try container.decode(String.self, forKey: .category)
    }
}

// MARK: - Hashable

extension Product: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
