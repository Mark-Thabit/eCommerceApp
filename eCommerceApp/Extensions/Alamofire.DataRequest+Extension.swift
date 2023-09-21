//
//  Alamofire.DataRequest+Extension.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import Alamofire

extension Alamofire.DataRequest {
    @discardableResult
    func logResponse() -> DataRequest {
        responseData { response in
#if DEBUG
            let json = try? JSONSerialization.jsonObject(with: response.data ?? Data(), options: JSONSerialization.ReadingOptions.allowFragments)
            print("\n\n++ Response Log is request url: \(String(describing: response.request?.url?.absoluteString ?? ""))\n\n")
            print("Request method: \(String(describing: response.request?.httpMethod ?? ""))\n\n")
            print("Request headers: \(String(describing: response.request?.allHTTPHeaderFields ?? [:]))\n\n")
            print("Request parameters: \(String(describing: String(data: response.request?.httpBody ?? Data(), encoding: .utf8) ?? ""))\n\n")
            print("Response value: \(String(describing: String(describing: json ?? "")))\n\n")
            print("Response headers: \(String(describing: response.response?.allHeaderFields ?? [:]))\n\n")
#endif
        }
        
        return self
    }
    
    @discardableResult
    func responseDecodable<T: Decodable>(request: Request,
                                         modelType: T.Type,
                                         success successCallback: @escaping (T) -> Void,
                                         failure failureHandler: FailureHandlerDelegate?) -> DataRequest {
        responseData { response in
            switch response.result {
                case let .success(data):
                    self.decodeResponse(data: data, modelType: modelType) { result in
                        switch result {
                            case let .success(model):
                                successCallback(model)
                                
                            case let .failure(error):
                                failureHandler?.handleGenericError(error, for: request)
                        }
                    }
                    
                case .failure(let error):
                    Logger.logError(error)
                    
                    let serverMsg = self.extractServerMessage(from: response.data)
                    
                    guard let requestError = self.mapError(error, serverMsg: serverMsg) else { return }
                    
                    failureHandler?.handleGenericError(requestError, for: request)
            }
        }
        
        return self
    }
    
    private func extractServerMessage(from data: Data?) -> String? {
        guard let data, let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else { return nil }
        return json["message"] as? String
    }
    
    private func decodeResponse<T: Decodable>(data: Data, modelType: T.Type, completion: (Result<T, RequestError>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = .current
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        let object: T
        
        do {
            object = try jsonDecoder.decode(modelType, from: data)
            completion(.success(object))
        } catch {
            Logger.logError(error)
            completion(.failure(.invalidResponse(msg: "Parsing issue")))
        }
    }
    
    private func mapError(_ error: AFError, serverMsg: String?) -> RequestError? {
        switch error {
            case .createUploadableFailed(let error):
                return .invalidRequest(msg: "Create Upload-able Failed with error: \(error)")
                
            case .createURLRequestFailed(let error):
                return .invalidRequest(msg: "Create URLRequest Failed with error: \(error)")
                
            case .downloadedFileMoveFailed(let error, let source, let destination):
                return .downloadedFileMoveFailed(source: source.absoluteString, destination: destination.absoluteString, msg: error.localizedDescription)
                
            case .explicitlyCancelled:
                return nil
                
            case .invalidURL(let url):
                return .invalidRequest(msg: "Invalid Url: \(url)")
                
            case .multipartEncodingFailed(let reason):
                return mapMultipartEncodingFailureError(with: reason)
                
            case .parameterEncodingFailed(let reason):
                return mapParameterEncodingFailureError(with: reason)
                
            case .parameterEncoderFailed(let reason):
                return mapParameterEncoderFailureError(with: reason)
                
            case .requestAdaptationFailed(let error):
                return .invalidRequest(msg: "Request Adaptation Failed with error: \(error)")
                
            case .requestRetryFailed(let retryError, let originalError):
                return .retryFailed(retryError: retryError, originalError: originalError)
                
            case .responseValidationFailed(let reason):
                return mapResponseValidationFailureError(with: error, reason: reason, serverMsg: serverMsg)
                
            case .responseSerializationFailed(let reason):
                return mapResponseSerializationFailureError(with: reason)
                
            case .serverTrustEvaluationFailed(let reason):
                switch reason {
                    default:
                        return .serverError(msg: error.localizedDescription, serverMsg: serverMsg)
                }
                
            case .sessionDeinitialized:
                return .sessionError(msg: "Session Deinitialized: \(error)")
                
            case .sessionInvalidated(let error):
                return .sessionError(msg: "Session Invalidated\(error == nil ? "" : ": \(error!)")")
                
            case .sessionTaskFailed(let error):
                switch (error as NSError).code {
                    case NSURLErrorTimedOut:
                        return .timeOut(msg: error.localizedDescription)
                        
                    case NSURLErrorNotConnectedToInternet:
                        return .connectionError(taskIsWaitingForConnectivity: HTTPRequest.sessionManager.session.configuration.waitsForConnectivity)
                        
                    case NSURLErrorDataNotAllowed:
                        return .connectionError(taskIsWaitingForConnectivity: HTTPRequest.sessionManager.session.configuration.waitsForConnectivity)
                        
                    default:
                        return .unknownError(msg: error.localizedDescription, serverMsg: serverMsg)
                }
                
            case .urlRequestValidationFailed(let reason):
                switch reason {
                    case .bodyDataInGETRequest(let data):
                        return .invalidRequest(msg: "URLRequest with GET method had body data: \(String(data: data, encoding: .utf8) ?? "N/E")")
                }
        }
    }
    
    private func mapMultipartEncodingFailureError(with reason: AFError.MultipartEncodingFailureReason) -> RequestError? {
        switch reason {
            case .bodyPartURLInvalid(let url):
                return .invalidRequest(msg: "Multipart Encoding - The fileURL provided for reading an encodable body part isn’t a file URL: \(url)")
                
            case .bodyPartFilenameInvalid(let url):
                return .invalidRequest(msg: "Multipart Encoding - The filename of the fileURL provided has either an empty lastPathComponent or `pathExtension: \(url)")
                
            case .bodyPartFileNotReachable(let url):
                return .invalidRequest(msg: "Multipart Encoding - The file at the fileURL provided was not reachable: \(url)")
                
            case .bodyPartFileNotReachableWithError(let url, let error):
                return .invalidRequest(msg: """
Multipart Encoding - Attempting to check the reachability of the fileURL: \(url)
provided threw an error: \(error)
""")
            case .bodyPartFileIsDirectory(let url):
                return .invalidRequest(msg: "Multipart Encoding - The file at the fileURL provided is actually a directory: \(url)")
                
            case .bodyPartFileSizeNotAvailable(let url):
                return .invalidRequest(msg: "Multipart Encoding - The size of the file at the fileURL provided was not returned by the system: \(url)")
                
            case .bodyPartFileSizeQueryFailedWithError(let url, let error):
                return .invalidRequest(msg: """
The attempt to find the size of the file at the fileURL: \(url)
provided threw an error: \(error)
""")
            case .bodyPartInputStreamCreationFailed(let url):
                return .invalidRequest(msg: "Multipart Encoding - An InputStream could not be created for the provided fileURL: \(url)")
                
            case .outputStreamCreationFailed(let url):
                return .invalidRequest(msg: "Multipart Encoding - An OutputStream could not be created when attempting to write the encoded data to disk: \(url)")
                
            case .outputStreamFileAlreadyExists(let url):
                return .invalidRequest(msg: "Multipart Encoding - The encoded body data could not be written to disk because a file already exists at the provided fileURL: \(url)")
                
            case .outputStreamURLInvalid(let url):
                return .invalidRequest(msg: "Multipart Encoding - The fileURL provided for writing the encoded body data to disk is not a file URL: \(url)")
                
            case .outputStreamWriteFailed(let error):
                return .invalidRequest(msg: "Multipart Encoding - The attempt to write the encoded body data to disk failed with an underlying error: \(error)")
                
            case .inputStreamReadFailed(let error):
                return .invalidRequest(msg: "Multipart Encoding - The attempt to read an encoded body part InputStream failed with underlying system error: \(error)")
        }
    }
    
    private func mapParameterEncodingFailureError(with reason: AFError.ParameterEncodingFailureReason) -> RequestError? {
        switch reason {
            case .missingURL:
                return .invalidRequest(msg: "Parameter Encoding - The URLRequest did not have a URL to encode")
                
            case .jsonEncodingFailed(let error):
                return .invalidRequest(msg: "Parameter Encoding - JSON serialization failed with an underlying system error during the encoding process: \(error)")
                
            case .customEncodingFailed(let error):
                return .invalidRequest(msg: "Parameter Encoding - Custom parameter encoding failed due to the associated Error: \(error)")
        }
    }
    
    private func mapParameterEncoderFailureError(with reason: AFError.ParameterEncoderFailureReason) -> RequestError? {
        switch reason {
            case .missingRequiredComponent(let requiredComponent):
                switch requiredComponent {
                    case .url:
                        return .invalidRequest(msg: "Parameter Encoder - The URL was missing or unable to be extracted from the passed URLRequest or during encoding")
                        
                    case .httpMethod(let value):
                        return .invalidRequest(msg: "Parameter Encoder - The HTTPMethod could not be extracted from the passed URLRequest: \(value)")
                }
                
            case .encoderFailed(let error):
                return .invalidRequest(msg: "Parameter Encoder - The underlying encoder failed with the associated error: \(error)")
        }
    }
    
    private func mapResponseValidationFailureError(with error: AFError, reason: AFError.ResponseValidationFailureReason, serverMsg: String?) -> RequestError? {
        switch reason {
            case .dataFileNil:
                return .invalidResponse(msg: "Response Validation - The data file containing the server response did not exist")
                
            case .dataFileReadFailed(let url):
                return .invalidResponse(msg: "Response Validation - The data file containing the server response at the associated URL could not be read: \(url)")
                
            case .missingContentType(let acceptableContentTypes):
                return .invalidResponse(msg: "Response Validation - The response did not contain a Content-Type and the acceptableContentTypes provided did not contain a wildcard type: \(acceptableContentTypes)")
                
            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                return .invalidResponse(msg: """
Response Validation - The response Content-Type did not match any type in the provided acceptableContentTypes
    - Acceptable Content Types: \(acceptableContentTypes)
    - Response Content Type: \(responseContentType)
""")
                
            case .unacceptableStatusCode(let code):
                switch code {
                    case 404:
                        return .notFound(msg: error.localizedDescription)
                        
                    case 401:
                        return .authorizationError(serverMsg: serverMsg)
                        
                    case 500 ... 599:
                        return .serverError(msg: error.localizedDescription, serverMsg: serverMsg)
                        
                    default:
                        return .unknownError(msg: error.localizedDescription, serverMsg: serverMsg)
                }
                
            case .customValidationFailed(let error):
                return .invalidResponse(msg: "Response Validation - Custom response validation failed due to the associated Error: \(error)")
        }
    }
    
    private func mapResponseSerializationFailureError(with reason: AFError.ResponseSerializationFailureReason) -> RequestError? {
        switch reason {
            case .inputDataNilOrZeroLength:
                return .invalidResponse(msg: "Response Serialization - The server response contained no data or the data was zero length")
                
            case .inputFileNil:
                return .invalidResponse(msg: "Response Serialization - The file containing the server response did not exist")
                
            case .inputFileReadFailed(let url):
                return .invalidResponse(msg: "Response Serialization - The file containing the server response could not be read from the associated URL: \(url)")
                
            case .stringSerializationFailed(let encoding):
                return .invalidResponse(msg: "Response Serialization - String serialization failed using the provided String.Encoding: \(encoding)")
                
            case .jsonSerializationFailed(let error):
                return .invalidResponse(msg: "Response Serialization - JSON serialization failed with an underlying system error: \(error)")
                
            case .decodingFailed(let error):
                return .invalidResponse(msg: "Response Serialization - A DataDecoder failed to decode the response due to the associated Error: \(error)")
                
            case .customSerializationFailed(let error):
                return .invalidResponse(msg: "Response Serialization - A custom response serializer failed due to the associated Error: \(error)")
                
            case .invalidEmptyResponse(let type):
                return .invalidResponse(msg: "Response Serialization - Generic serialization failed for an empty response that wasn’t type Empty but instead the associated type: \(type)")
        }
    }
}
