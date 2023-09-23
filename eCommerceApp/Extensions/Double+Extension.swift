//
//  Double+Extension.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 23/09/2023.
//

import Foundation

extension Double {
    var asFormattedCurrency: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: self as NSNumber)
    }
}
