//
//  Reusable.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import Foundation

protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

typealias NibReusable = Reusable & NibLoadable

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
