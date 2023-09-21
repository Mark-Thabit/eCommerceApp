//
//  Connectivity.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Alamofire

class Connectivity {
    static var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
