//
//  Session.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 12/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public enum NetworkParserType {
    case json
    case data
}

public final class NetworkSession {
    public static let shared = NetworkSession()

    private var urlSession: URLSession = URLSession()
    public var userAgent: String = ""
    public var defaultHeaders: [String: Any]?

    private var networkLogger: NetworkLogger?
    private var retryConfiguration: RetryConfiguration?
    private var authorization: Authorization?

    private init() {
    }

    public func setup(urlSession: URLSession, authorization: Authorization? = nil, logger: NetworkLogger?, retryConfiguration: RetryConfiguration? = nil, userAgent: String = "") {
        self.urlSession = urlSession
        self.authorization = authorization
        self.networkLogger = logger
        self.retryConfiguration = retryConfiguration
        self.userAgent = userAgent
    }

    // MARK: - request
    public func dataTask<ToType: Decodable >(
        _ request: URLRequest,
        parserType: NetworkParserType = .json,
        toType: ToType.Type,
        completionHandler: @escaping (_ result: Result<Any, AnyError>) -> Void) {
        var requestVar = request
        if let defaultHeaders = defaultHeaders {
            for header in defaultHeaders where request.value(forHTTPHeaderField: header.key) == nil {
                requestVar.setValue(header.value as? String, forHTTPHeaderField: header.key)
            }
        }
        networkLogger?.willStartRequest(requestVar)

        urlSession.dataTask(with: requestVar) { [weak self] (data, response, error) in
            guard let strongSelf = self else {
                return
            }
            let httpResponse = response as? HTTPURLResponse
            let responseObject = Response(data: data, response: httpResponse, error: error as? NetworkingError)

            strongSelf.networkLogger?.didFinishRequest(requestVar, response: httpResponse, parserType: parserType, toType: toType, data: responseObject.data)

            if error == nil && (httpResponse?.statusCode == 200 ||
                httpResponse?.statusCode == 210) {
                completionHandler(NetworkParser(parserType: parserType, toType: toType, data: responseObject.data).result)
            } else if httpResponse?.statusCode == 401 {
                guard let authorization = strongSelf.authorization else {
                    completionHandler(.failure(
                        AnyError(NetworkingError.authorizationError(underlyingError: .noauthorizationdefined))))
                    return
                }
                authorization.authorize(completionHandler: { (result) in
                    switch result {
                    case .success:
                        strongSelf.retryWithDelay(retryDelaySession: strongSelf.retryConfiguration?.retryDelay, retryDelayRequest: request.retryConfiguration?.retryDelay, request: requestVar, parserType: parserType, toType: toType, responseObject: responseObject, completionHandler: { (response) in
                            completionHandler(NetworkParser(parserType: parserType, toType: toType, data: responseObject.data).result)
                        })
                    case .failure:
                        completionHandler(.failure(AnyError(
                            NetworkingError.authorizationError(underlyingError: .authorizationFailed))))
                    }
                })
            } else if httpResponse?.statusCode == 403 ||
                httpResponse?.statusCode == 410 ||
                httpResponse?.statusCode == 429 {
                // to fail
                completionHandler(.failure(AnyError(NetworkingError.dataTaskError(underlyingError: .responseFailed, statuscode: httpResponse?.statusCode ?? 0))))
            } else if error != nil && strongSelf.shouldCancelRequestbyError(error!) {
                // to fail
                completionHandler(.failure(AnyError(NetworkingError.dataTaskError(underlyingError: .responseFailed, statuscode: httpResponse?.statusCode ?? 0))))
            } else {
                // reachability
                if error != nil &&
                    (httpResponse?.statusCode == NSURLErrorNotConnectedToInternet ||
                        httpResponse?.statusCode == NSURLErrorTimedOut ||
                        httpResponse?.statusCode == NSURLErrorCannotFindHost ||
                        httpResponse?.statusCode == NSURLErrorCannotConnectToHost) {
                    // for now disabled
                    completionHandler(.failure(AnyError(NetworkingError.dataTaskError(underlyingError: .responseFailed, statuscode: httpResponse?.statusCode ?? 0))))
                    // when it needs to be enabled remove previous line and uncomment next line
                    //self.handleReachability()
                } else {
                    // retrier
                    strongSelf.retryWithDelay(retryDelaySession: strongSelf.retryConfiguration?.retryDelay, retryDelayRequest: request.retryConfiguration?.retryDelay, request: requestVar, parserType: parserType, toType: toType, responseObject: responseObject, completionHandler: { (response) in
                        completionHandler(NetworkParser(parserType: parserType, toType: toType, data: responseObject.data).result)
                    })
                }
            }
            }.resume()

    }

    private func handleReachability() {
    }

    private func retryWithDelay<ToType: Decodable>(retryDelaySession: Double?, retryDelayRequest: Double?, request: URLRequest, parserType: NetworkParserType, toType: ToType.Type, responseObject: Response, completionHandler: @escaping (_ result: Result<Any, AnyError>) -> Void) {
        var newRequest = request
        var retryDelayCalculated: Double = 0
        var maximumretryDelay: Double = 0
        var hasDelay: Bool = false

        if let retryDelayRequest = request.retryConfiguration?.retryDelay, retryDelayRequest > 0 {
            // delay by request
            hasDelay = true
            retryDelayCalculated = retryDelayRequest
            maximumretryDelay = request.retryConfiguration?.maximumretryDelay ?? 0
        } else if let retryDelay = self.retryConfiguration?.retryDelay, retryDelay > 0 {
            // delay by session
            hasDelay = true
            retryDelayCalculated = retryDelay
            maximumretryDelay = self.retryConfiguration?.maximumretryDelay ?? 0
            newRequest.retryConfiguration?.retryDelay = NetworkSession.shared.retryConfiguration?.retryDelay ?? 0
        } else {
            // no delay
            completionHandler(NetworkParser(parserType: parserType, toType: toType, data: responseObject.data).result)
            return
        }

        if hasDelay {
            let newretryDelay = retryDelayCalculated + 1

            newRequest.retryConfiguration?.retryDelay = newretryDelay

            if newretryDelay > maximumretryDelay {
                completionHandler(.failure(AnyError(NetworkingError.dataTaskError(underlyingError: .tooManyAttempts, statuscode: 0))))
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(newretryDelay))) {
                    self.dataTask(newRequest, parserType: parserType, toType: toType, completionHandler: { (response) in
                        completionHandler(NetworkParser(parserType: parserType, toType: toType, data: responseObject.data).result)
                    })
                }
            }
        }

    }

    /// shouldCancelRequestbyError: if the request error non temporary then we fail and cancel any further request
    /// - parameter error: Error received by the request
    /// - returns: Bool
    private func shouldCancelRequestbyError(_ error: Error) -> Bool {
        if ((error._domain == "NSURLErrorDomain" && (
            error._code == NSURLErrorCancelled ||
                error._code == NSURLErrorBadURL ||
                error._code == NSURLErrorUnsupportedURL ||
                error._code == NSURLErrorDataLengthExceedsMaximum ||
                error._code == NSURLErrorHTTPTooManyRedirects ||
                error._code == NSURLErrorUserCancelledAuthentication ||
                error._code == NSURLErrorRequestBodyStreamExhausted ||
                error._code == NSURLErrorAppTransportSecurityRequiresSecureConnection ||
                error._code == NSURLErrorFileDoesNotExist ||
                error._code == NSURLErrorFileIsDirectory ||
                error._code == NSURLErrorNoPermissionsToReadFile ||
                error._code == NSURLErrorSecureConnectionFailed ||
                error._code == NSURLErrorServerCertificateHasBadDate ||
                error._code == NSURLErrorServerCertificateUntrusted ||
                error._code == NSURLErrorServerCertificateHasUnknownRoot ||
                error._code == NSURLErrorServerCertificateNotYetValid ||
                error._code == NSURLErrorClientCertificateRejected ||
                error._code == NSURLErrorClientCertificateRequired ||
                error._code == NSURLErrorCannotCreateFile ||
                error._code == NSURLErrorCannotOpenFile ||
                error._code == NSURLErrorCannotCloseFile ||
                error._code == NSURLErrorCannotWriteToFile ||
                error._code == NSURLErrorCannotRemoveFile ||
                error._code == NSURLErrorCannotMoveFile))
            ||
            (error._domain == "NSCocoaErrorDomain" && (
                error._code == 3840))
            ) {
            return true
        } else {
            return false
        }
    }

    // MARK: - Other operations

    public func cancelAllTasks() {
        urlSession.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            for task in dataTasks {
                task.cancel()
            }
            for task in uploadTasks {
                task.cancel()
            }
            for task in downloadTasks {
                task.cancel()
            }
        }
    }

}
