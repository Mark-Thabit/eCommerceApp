//
//  RequestError.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Foundation

public enum RequestError: LocalizedError {
    case unknownError(msg: String, serverMsg: String?)
    case connectionError(taskIsWaitingForConnectivity: Bool)
    case authorizationError(serverMsg: String?)
    case notFound(msg: String)
    case invalidResponse(msg: String)
    case invalidRequest(msg: String)
    case serverError(msg: String, serverMsg: String?)
    case timeOut(msg: String)
    case downloadedFileMoveFailed(source: String, destination: String, msg: String)
    case retryFailed(retryError: Error, originalError: Error)
    case sessionError(msg: String)
    case requestCanceled
    
    public var errorDescription: String? {
        switch self {
            case let .unknownError(msg, serverMsg): return serverMsg ?? msg
            case .connectionError: return "Check your connection"
            case let .authorizationError(serverMsg): return serverMsg ?? "Unauthorized"
            case let .notFound(msg): return msg
            case let .invalidResponse(msg): return msg
            case let .invalidRequest(msg): return msg
            case let .serverError(msg, serverMsg): return serverMsg ?? msg
            case let .timeOut(msg): return msg
            case .downloadedFileMoveFailed: return "Failed to move downloaded file"
            case let .retryFailed(retryError, originalError): return "Retry Failed with error: \(retryError)\nOriginal error: \(originalError)"
            case let .sessionError(msg): return msg
            case .requestCanceled: return "Canceled"
        }
    }
}
