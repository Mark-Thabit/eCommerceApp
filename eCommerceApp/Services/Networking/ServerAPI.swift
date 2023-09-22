//
//  ServerAPI.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Alamofire

enum ServerAPI {
    case fetchProductList
    case fetchCategoryList
    case fetchCategoryProductList(category: String)
}

extension ServerAPI: Request {
    var baseURL: String { Bundle.main.object(forInfoDictionaryKey: Constants.Keys.kBaseURL) as? String ?? "" }
    
    var path: String {
        switch self {
            case .fetchProductList: "/products"
            case .fetchCategoryList: "/products/categories"
            case let .fetchCategoryProductList(category): "/products/category/\(category)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
            case .fetchProductList: .get
            case .fetchCategoryList: .get
            case .fetchCategoryProductList: .get
        }
    }
    
    var parameters: Parameters? {
        let parameters: Parameters = [:]
        
        switch self {
            case .fetchProductList: break
            case .fetchCategoryList: break
            case .fetchCategoryProductList: break
        }
        
        return parameters
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
