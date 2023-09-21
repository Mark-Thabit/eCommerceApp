//
//  Request.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Alamofire

public protocol Request {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
}
