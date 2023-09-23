//
//  Cart.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Foundation
import CoreData

class Cart {
    
    // MARK: - Singleton
    
    static var current = Cart()
    
    // MARK: - iVars
    
    var itemList: [CartItem] = []
    
    // MARK: - Initializers
    
    private init() {
        itemList = loadCache()
    }
    
    // MARK: - Helper Methods
    
    private func loadCache() -> [CartItem] {
        let fetchRequest = CartItem.fetchRequest()
        
        do {
            return try CoreData.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            Logger.logError(error)
            return []
        }
    }
    
    func addItem(with id: Int, qty: Int) {
        if let item = itemList.first(where: { $0.productId == id }) { // Already exists
            item.qty += 1
        } else { // First to add
            let item = CartItem(context: CoreData.persistentContainer.viewContext)
            item.productId = Int64(id)
            item.qty = Int16(qty)
            itemList.append(item)
        }
    }
    
    func removeItem(with id: Int) -> Bool {
        guard let item = itemList.first(where: { $0.productId == id }) else { return false }
        
        CoreData.persistentContainer.viewContext.delete(item)
        return true
    }
    
    func reset() {
        let patchDeleteReq = NSBatchDeleteRequest(fetchRequest: CartItem.fetchRequest())
        
        do {
            try CoreData.persistentContainer.viewContext.execute(patchDeleteReq)
            itemList.removeAll()
        } catch {
            Logger.logError(error)
        }
    }
}
