//
//  ServerAPI.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Alamofire

enum ServerAPI {
    case fetchProductList
}

extension ServerAPI: Request {
    var baseURL: String { Bundle.main.object(forInfoDictionaryKey: Constants.Keys.kBaseURL) as? String ?? "" }
    
    var path: String {
        switch self {
            case .fetchProductList: "/products"
        }
    }
    
    var method: HTTPMethod {
        switch self {
            case .fetchProductList: .get
        }
    }
    
    var parameters: Parameters? {
        let parameters: Parameters = [:]
        
        switch self {
            case .fetchProductList: break
        }
        
        return parameters
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
