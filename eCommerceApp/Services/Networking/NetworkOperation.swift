//
//  NetworkOperation.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Foundation

public class NetworkOperation<T: Decodable>: Operation {
    
    typealias OperationSuccessHandler = (_ result: T) -> Void
    typealias OperationFailureHandler = (_ error: RequestError, _ request: Request) -> Void
    
    // MARK: - iVars
    
    var successHandler: OperationSuccessHandler?
    var failureHandler: OperationFailureHandler?
    weak var failureDelegate: FailureHandlerDelegate?
    
    // MARK: - State
    
    /// State stored as an enum
    private enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    private var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    public override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    // MARK: - Life cycle
    
    public override func start() {
        guard !isCancelled else { return finish() }
        
        if !isExecuting { state = .executing }
        
        main()
    }
    
    public override func cancel() {
        super.cancel()
        
        finish()
    }
    
    // MARK: - Helper Methods
    
    func finish() {
        if isExecuting { state = .finished }
    }
    
    func complete(with result: T) {
        finish()
        
        if !isCancelled { successHandler?(result) }
    }
}

// MARK: - FailureHandlerDelegate

extension NetworkOperation: FailureHandlerDelegate {
    public func handleGenericError(_ error: RequestError, for request: Request) {
        guard !isCancelled else { return }
        
        if case let .connectionError(taskIsWaitingForConnectivity) = error, taskIsWaitingForConnectivity {
            // Do nothing and wait for connectivity
        } else {
            finish()
        }
        
        DispatchQueue.main.async {
            self.failureHandler?(error, request)
            self.failureDelegate?.handleGenericError(error, for: request)
        }
    }
}
