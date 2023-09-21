//
//  FailureHandlerDelegate.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Foundation

protocol FailureHandlerDelegate: AnyObject {
    func handleGenericError(_ error: RequestError, for request: Request)
}
