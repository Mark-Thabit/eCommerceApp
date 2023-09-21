//
//  Product.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

extension Product {
    static var dummyList: [Product] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var list: [Product] = []
        
        for index in 0...10 {
            let product = Product(context: appDelegate.persistentContainer.viewContext)
            product.id = Int64(index)
            product.title = "long product name with two lines"
            product.imagePath = "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg"
            product.desc = "Some Desc"
            product.price = 12.5
        
            list.append(product)
        }
        
        return list
    }
}
