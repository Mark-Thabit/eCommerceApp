//
//  OperationManager.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Foundation

public class OperationManager {
    
    // MARK: - Singleton
    
    static let shared = OperationManager()
    
    // MARK: - iVars
    
    lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Network calls queue"
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Helper Methods
    
    func addOperation(_ op: Operation) {
        queue.addOperation(op)
    }
    
    func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        guard wait else { return queue.addOperations(ops, waitUntilFinished: wait) }
        
        // Blocking main thread can cause deadlock
        DispatchQueue.global(qos: .default).async {
            self.queue.addOperations(ops, waitUntilFinished: wait)
        }
    }
    
    func addBarrierBlock(_ barrier: @escaping () -> Void) {
        queue.addBarrierBlock(barrier)
    }
}
