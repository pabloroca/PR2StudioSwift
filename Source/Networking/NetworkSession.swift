//
//  Session.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 12/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public final class NetworkSession {
    public static let shared = NetworkSession()

    private var urlSession: URLSession = URLSession()
    public var userAgent: String = ""
    public var defaultHeaders: [String: Any]?

    private var networkLogger: NetworkLogger?
    private var retryConfiguration: RetryConfiguration?

    private init() {
    }

    public func setup(urlSession: URLSession, logger: NetworkLogger?, retryConfiguration: RetryConfiguration? = nil, userAgent: String = "") {
        self.urlSession = urlSession
        self.networkLogger = logger
        self.retryConfiguration = retryConfiguration
        self.userAgent = userAgent
    }

    // MARK: - request
    public func dataTask(
        _ request: URLRequest,
        completionHandler: @escaping (_ response: Response) -> Void) {
        var requestVar = request
        if let defaultHeaders = defaultHeaders {
            for header in defaultHeaders where request.value(forHTTPHeaderField: header.key) == nil {
                requestVar.setValue(header.value as? String, forHTTPHeaderField: header.key)
            }
        }
        networkLogger?.willStartRequest()

        urlSession.dataTask(with: requestVar) { [weak self] (data, response, error) in
            guard let self = self else {
                return
            }
            let httpResponse = response as? HTTPURLResponse

            let responseObject = Response(data: data, response: httpResponse, error: error as? NetworkingError)

            self.networkLogger?.didFinishRequest()

            if error == nil && (httpResponse?.statusCode == 200 ||
                httpResponse?.statusCode == 210) {
                // to parse
                completionHandler(responseObject)
            } else if httpResponse?.statusCode == 401 ||
                httpResponse?.statusCode == 403 ||
                httpResponse?.statusCode == 410 ||
                httpResponse?.statusCode == 429 {
                // to fail
                completionHandler(responseObject)
            } else if error != nil && self.shouldCancelRequestbyError(error!) {
                // to fail
                completionHandler(responseObject)
            } else {
                // posible not having internet, we wait for reachability
                if error != nil &&
                    (httpResponse?.statusCode == NSURLErrorNotConnectedToInternet ||
                        httpResponse?.statusCode == NSURLErrorTimedOut ||
                        httpResponse?.statusCode == NSURLErrorCannotFindHost ||
                        httpResponse?.statusCode == NSURLErrorCannotConnectToHost) {
                    // reachability
                } else {
                    // retrier
                    var retryDelayCalculated: Double = 0
                    var retryMode: RetryMode = .session

                    if let retryDelayRequest = request.retryConfiguration?.retryDelay, retryDelayRequest > 0 {
                        retryDelayCalculated = retryDelayRequest
                        retryMode = .request
                    } else if let retryDelay = self.retryConfiguration?.retryDelay, retryDelay > 0 {
                        retryDelayCalculated = retryDelay
                    }
                    self.retryWithDelay(retryDelayCalculated, retryMode: retryMode, request: requestVar, responseObject: responseObject, completionHandler: { (response) in
                        let responseObject = Response(data: response.data, response: response.response, error: response.error)
                        completionHandler(responseObject)
                    })
                }
            }
            }.resume()

    }

    private func retryWithDelay(_ retryDelay: Double, retryMode: RetryMode, request: URLRequest, responseObject: Response, completionHandler: @escaping (_ response: Response) -> Void) {
        var maximumretryDelay: Double = 0
        var newRequest = request
        let newretryDelay = retryDelay + 1

        switch retryMode {
        case .request:
            maximumretryDelay = request.retryConfiguration?.maximumretryDelay ?? 0
        case .session:
            maximumretryDelay = self.retryConfiguration?.maximumretryDelay ?? 0
            newRequest.retryConfiguration?.retryDelay = NetworkSession.shared.retryConfiguration?.retryDelay ?? 0
        }

        newRequest.retryConfiguration?.retryDelay = newretryDelay

        if newretryDelay > maximumretryDelay {
            completionHandler(responseObject)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(newretryDelay))) {
                self.dataTask(newRequest, completionHandler: { (response) in
                    let httpResponse = response.response
                    let responseObject = Response(data: response.data, response: httpResponse, error: response.error)
                    completionHandler(responseObject)
                })
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
