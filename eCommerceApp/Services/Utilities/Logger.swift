//
//  Logger.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Foundation

final class Logger {
    
    // MARK: - Class functions
    
    class func log(_ items: Any...) {
#if DEBUG
        guard !items.isEmpty else { return print() }
        
        let lineSeperator = "***************************************"
        print("\n\(lineSeperator)\n")
        items.forEach { print($0) }
        print("\n\(lineSeperator)\n")
#endif
    }
    
    class func logError(_ items: Any...) {
#if DEBUG
        guard !items.isEmpty else { return print() }
        
        print("App Error: ", terminator: "")
        items.forEach { print($0) }
#endif
    }
}
