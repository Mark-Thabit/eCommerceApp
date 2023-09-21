//
//  NetworkLogger.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Alamofire

class NetworkLogger: EventMonitor {
    let queue = DispatchQueue(label: "com.styrk.networklogger") // EventMonitor requires a DispatchQueue which dispatches all events.
    
    func requestDidFinish(_ request: Alamofire.Request) {
        Logger.log(request.description)
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
#if DEBUG
        if let data = response.data {
            let requestHeaders = response.request?.allHTTPHeaderFields ?? [:]
            let parameters = String(data: response.request?.httpBody ?? Data(), encoding: .utf8) ?? "[]"
            let responseText = (try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])) ?? "N/E"
            let responseHeaders = String(describing: response.response?.allHeaderFields ?? [:])
            
            Logger.log("""
\(request)

Request Headers: \(requestHeaders)

Parameters: \(parameters.isEmpty ? "[]" : parameters)

Response: \(responseText)

Response Headers: \(responseHeaders)
""")
        }
#endif
    }
}
