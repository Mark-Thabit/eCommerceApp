//
//  HTTPRequest.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Alamofire

struct HTTPRequest {
    
    // MARK: - Class Vars
    
    static var currentRequest: DataRequest!
    static let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.waitsForConnectivity = false // If true then timeout limit is ignored - set it to false so session consider the timeout limit
//        configuration.timeoutIntervalForResource = 300 // Set to 5 Min - How long the session waits for connectivity depends on the session resource timeout
        
        let responseCacher = ResponseCacher(behavior: .doNotCache)
        let networkLogger = NetworkLogger()
        let interceptor = Interceptor()
        
        return Session(
            configuration: configuration,
            interceptor: interceptor,
            cachedResponseHandler: responseCacher,
            eventMonitors: [networkLogger])
    }()
    
    // MARK: - Class Functions
    
    static func request<T: Decodable>(_ request: Request,
                                      modelType: T.Type,
                                      success successCallback: @escaping (T) -> Void,
                                      failure failureHandler: FailureHandlerDelegate?) {
        
        if !Connectivity.isConnectedToInternet {
            failureHandler?.handleGenericError(RequestError.connectionError(taskIsWaitingForConnectivity: sessionManager.session.configuration.waitsForConnectivity),
                                               for: request)
        }
        
        let fullUrl = "\(request.baseURL)\(request.path)"
        
        currentRequest = sessionManager.request(fullUrl,
                                                method: request.method,
                                                parameters: request.parameters,
                                                headers: request.headers) //{ $0.timeoutInterval = timeoutInterval }
        .validate()
        .responseDecodable(request: request, modelType: modelType, success: successCallback, failure: failureHandler)
    }
    
    static func requestMultiPart<T: Decodable>(_ request: Request,
                                               modelType: T.Type,
                                               success successCallback: @escaping (T) -> Void,
                                               failure failureHandler: FailureHandlerDelegate?) {
        
        if !Connectivity.isConnectedToInternet {
            failureHandler?.handleGenericError(RequestError.connectionError(taskIsWaitingForConnectivity: sessionManager.session.configuration.waitsForConnectivity),
                                               for: request)
        }
        
        let fullUrl = "\(request.baseURL)\(request.path)"
        currentRequest = sessionManager.upload(multipartFormData: { multipartFormData in
            request.parameters?.forEach { key, value in
                if let data = value as? Data {
                    multipartFormData.append(data, withName: key)
                } else if let data = "\(value)".data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
        },
                                               to: fullUrl,
                                               usingThreshold: MultipartFormData.encodingMemoryThreshold,
                                               method: request.method,
                                               headers: request.headers)
        .validate()
        .responseDecodable(request: request, modelType: modelType, success: successCallback, failure: failureHandler)
    }
    
    static func isRequestExistsInSession(request: Request, completion: @escaping (Bool) -> Void) {
        sessionManager.session.getAllTasks { taskList in
            let isExists = taskList.contains(where: { $0.currentRequest?.url?.absoluteString == (request.baseURL + request.path) })
            DispatchQueue.main.async { completion(isExists) }
        }
    }
}
