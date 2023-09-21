//
//  RequestOperation.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Foundation

public final class RequestOperation<T: Decodable>: NetworkOperation<T> {
    
    // MARK: - iVars
    
    let request: Request
    let decodeType: T.Type
    
    // MARK: - Initializers
    
    init(request: Request, decodeType: T.Type, failureDelegate: FailureHandlerDelegate? = nil) {
        self.request = request
        self.decodeType = decodeType
        
        super.init()
        super.failureDelegate = failureDelegate
    }
    
    // MARK: - Main
    
    public override func main() {
        guard !isCancelled else { return }
        
        HTTPRequest.request(request,
                            modelType: decodeType,
                            success: { [weak self] response in
            guard let self = self, !self.isCancelled else { return }
            self.complete(with: response)
        },
                            failure: self)
    }
    
    public override func cancel() {
        failureHandler?(.requestCanceled, request)
        failureDelegate?.handleGenericError(.requestCanceled, for: request)
        
        super.cancel()
    }
}

public final class RequestMultiPartOperation<T: Decodable>: NetworkOperation<T> {
    
    // MARK: - iVars
    
    let request: Request
    let decodeType: T.Type
    
    // MARK: - Initializers
    
    init(request: Request, decodeType: T.Type, failureDelegate: FailureHandlerDelegate? = nil) {
        self.request = request
        self.decodeType = decodeType
        
        super.init()
        super.failureDelegate = failureDelegate
    }
    
    // MARK: - Main
    
    public override func main() {
        guard !isCancelled else { return }
        
        HTTPRequest.requestMultiPart(request,
                                     modelType: decodeType,
                                     success: { [weak self] response in
            guard let self = self, !self.isCancelled else { return }
            self.complete(with: response)
        },
                                     failure: self)
    }
    
    public override func cancel() {
        failureHandler?(.requestCanceled, request)
        failureDelegate?.handleGenericError(.requestCanceled, for: request)
        
        super.cancel()
    }
}
