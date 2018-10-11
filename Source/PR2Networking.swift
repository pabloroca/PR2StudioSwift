//
//  PR2Networking.swift
//
//  Created by Pablo Roca Rozas on 22/01/2016.
//  Copyright © 2016 PR2Studio. All rights reserved.
//

import Foundation
import Alamofire

/// Networking log levels
public enum PR2NetworkingLogLevel {
    /// PR2Networking log disabled
    case pr2NetworkingLogLevelOff
    /// PR2Networking log in debug mode
    case pr2NetworkingLogLevelDebug
    /// PR2Networking log with short info
    case pr2NetworkingLogLevelInfo
    /// PR2Networking log when errors
    case pr2NetworkingLogLevelError
}

/// HTTP error codes
public enum PR2HTTPCode {
    // Success
    /// HTTP 200 OK
    case c200OK

    /// HTTP 201 Created
    case c201OK

    /// HTTP Error 304 Redirection
    case c304NotModified

    // Client error
    /// HTTP Error 400 Bad request
    case c400BadRequest
    /// HTTP Error 401 Unauthorised
    case c401Unauthorised
    /// HTTP Error 403 Forbidden
    case c403Forbidden
    /// HTTP Error 404 Not found
    case c404NotFound
    /// HTTP Error 405 Method not allowed
    case c405MethodNotAllowed
    /// HTTP Error 410 Gone
    case c410Gone
    /// HTTP Error 429 Too Many Requests
    case c429TooManyRequests

    // Server error
    /// HTTP Error 500 Internsal server error
    case c500InternalServerError
    case other

    public init(value: Int) {
        switch value {
        case 200:
            self = .c200OK
        case 201:
            self = .c201OK
        case 304:
            self = .c304NotModified
        case 400:
            self = .c400BadRequest
        case 401:
            self = .c401Unauthorised
        case 403:
            self = .c403Forbidden
        case 404:
            self = .c404NotFound
        case 405:
            self = .c405MethodNotAllowed
        case 410:
            self = .c410Gone
        case 500:
            self = .c500InternalServerError
        default:
            self = .other
        }
    }
}

/// Slow Internet Notification
public struct PR2NetworkingNotifications {
    /// slow internet
    public static let slowInternet = "com.pr2studio.notifications.SlowInternet"
}

/// Main network request class (wrapper of Alamofire request)
public class PR2Networking {
    /// it converts itself as a singleton
    public static let sharedInstance = PR2Networking()

    /// Networking log levels
    public var logLevel: PR2NetworkingLogLevel = .pr2NetworkingLogLevelOff

    public var tasks: [PR2NetworkTask] = []

    lazy var downloadsInProgress = [IndexPath: Operation]()
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        //      queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount
        //      queue.maxConcurrentOperationCount = 1
        return queue
    }()

    /// initial retry delay
    let retryDelay: Double = 1.0  // in seconds

    /// seconds to trigger slow internet notification
    let secondsToShowSlowConnection: Double = 3
    /// timer for slow internet
    var timerRequest = Timer()

    /// alamofire manager
    var manager: Alamofire.SessionManager?
    /// alamofire reachability
    #if os(iOS)
    var managerReachability: NetworkReachabilityManager?
    #endif

    /// This private prevents others from using the default '()' initializer for this class.
    private init() {
        var defaultHeaders = Alamofire.SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
        defaultHeaders["User-Agent"] = self.userAgent()

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        //cache disabled completely
        configuration.urlCache = nil
        self.manager = Alamofire.SessionManager(configuration: configuration)

    }

    public func addTask(_ task: PR2NetworkTask) {
        let mytask = task
        mytask.status = PR2NetworkTaskStatus.statusRunning
        self.tasks.append(mytask)

        self.downloadQueue.addOperation(mytask)

        print("task added %@", mytask.url)
    }

    public func addTaskAfterLast(_ task: PR2NetworkTask) {
        let mytask = task
        mytask.status = PR2NetworkTaskStatus.statusRunning
        self.tasks.append(mytask)

        self.downloadQueue.addOperationAfterLast(mytask)

        print("task added %@", mytask.url)
    }

    // MARK: - request methods

    /// request: Recursive Request till delay > 30 seconds
    ///  - parameter delay:      Acumulated delay
    ///  - parameter method:     The HTTP method.
    ///  - parameter urlString:  The URL string.
    ///  - parameter parameters: The parameters. nil by default.
    ///  - parameter encoding:   The parameter encoding. .URL by default.
    ///  - parameter headers:    The HTTP headers. nil by default.
    ///  - parameter completionHandler:    Completion handler.
    public func request(
        _ delay: Double,
        method: HTTPMethod,
        urlString: String,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String]? = nil,
        completionHandler: @escaping (_ success: Bool, _ response: DataResponse<Any>) -> Void) {
        willStartRequest(method, urlString, parameters: parameters, encoding: encoding, headers: headers)

        Alamofire.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                var statusCode: PR2HTTPCode
                if let httpError = response.result.error {
                    statusCode = PR2HTTPCode(value: httpError._code)
                } else { //no errors
                    statusCode = PR2HTTPCode(value: (response.response?.statusCode)!)
                }

                // let cachedURLResponse = NSCachedURLResponse(response: response.response!, data: response.data!, userInfo: nil, storagePolicy: .Allowed)
                // NSURLCache.sharedURLCache().storeCachedResponse(cachedURLResponse, forRequest: response.request!)

                // success
                if (response.result.error == nil && (statusCode == PR2HTTPCode.c200OK || statusCode == PR2HTTPCode.c201OK)) {
                    strongSelf.didFinishRequest(true, response)
                    completionHandler(true, response)
                } else if (statusCode == PR2HTTPCode.c403Forbidden || statusCode == PR2HTTPCode.c410Gone || statusCode == PR2HTTPCode.c429TooManyRequests) {
                    strongSelf.didFinishRequest(false, response)
                    completionHandler(false, response)
                } else {
                    // don't repeat the network call if error not temporary
                    let error = response.result.error as! AFError
                    if (response.result.error != nil && strongSelf.shouldCancelRequestbyError(error)) {
                        strongSelf.didFinishRequest(false, response)
                        completionHandler(false, response)
                    } else {
                        // posibble not having internet, we wait for reachability
                        if (response.result.error != nil &&
                            (response.response?.statusCode == NSURLErrorNotConnectedToInternet ||
                                response.response?.statusCode == NSURLErrorTimedOut ||
                                response.response?.statusCode == NSURLErrorCannotFindHost ||
                                response.response?.statusCode == NSURLErrorCannotConnectToHost)
                            ) {
                            let host = response.request!.url!.host
                            #if os(iOS)
                            strongSelf.managerReachability = NetworkReachabilityManager(host: host!)
                            strongSelf.managerReachability!.listener = { status in
                                // is again reachable? we make the request again
                                if (strongSelf.managerReachability!.isReachable) {
                                    strongSelf.managerReachability!.stopListening()
                                    strongSelf.didFinishRequest(false, response)
                                    strongSelf.request(delay, method: method, urlString: urlString, completionHandler: { (success, response) -> Void in
                                        completionHandler(success, response)
                                    })
                                }
                            }

                            strongSelf.managerReachability!.startListening()
                            #endif
                        } else {
                            strongSelf.didFinishRequest(false, response)
                            // failure then we retry request
                            let newretryDelay = delay + 1
                            if newretryDelay > 30 {
                                completionHandler(false, response)
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(newretryDelay))) {
                                    strongSelf.request(newretryDelay, method: method, urlString: urlString, completionHandler: { (success, response) -> Void in
                                        completionHandler(success, response)
                                    })
                                }
                            }
                        }
                    }
                }
        }
    }

    // MARK: - start and finish request common functions

    /// willStartRequest: Executed before any request (activity indicator & console logger)
    /// - parameter method:     The HTTP method.
    /// - parameter uRLString:  The URL string.
    /// - parameter parameters: The parameters. nil by default.
    /// - parameter encoding:   The parameter encoding. .URL by default.
    /// - parameter headers:    The HTTP headers. nil by default.
    private func willStartRequest(
        _ method: HTTPMethod,
        _ uRLString: String,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String]? = nil
        ) {
        self.timerRequest = Timer.scheduledTimer(timeInterval: self.secondsToShowSlowConnection, target: self, selector: #selector(self.timerRequestReached), userInfo: nil, repeats: false)

        PR2Common().showNetworkActivityinStatusBar()

        /// network console logger
        let dateString  = Date().PR2DateFormatterForLog()

        switch self.logLevel {
        case .pr2NetworkingLogLevelOff, .pr2NetworkingLogLevelError:
            break
        case .pr2NetworkingLogLevelDebug:

            // headers
            var dictDefaultHeaders: Dictionary = self.manager!.session.configuration.httpAdditionalHeaders!
            // adds custom headers to default headers
            if let myHeaders = headers {
                for (key, value) in myHeaders {
                    dictDefaultHeaders.updateValue(value, forKey: key)
                }
            }
            // prepare dictDefaultHeaders for printing
            var stringDefaultHeaders = ""
            for (key, value) in dictDefaultHeaders {
                stringDefaultHeaders += "\(key): \(value)\n"
            }
            let index1 = stringDefaultHeaders.index(stringDefaultHeaders.endIndex, offsetBy: -1)
            stringDefaultHeaders = String(stringDefaultHeaders[..<index1])
            // parameters
            var stringParameters = ""
            if let myParameters = parameters {
                for (key, value) in myParameters {
                    stringParameters += "\(key): \(value)\n"
                }
                let index1 = stringParameters.index(stringParameters.endIndex, offsetBy: -1)
                stringParameters = String(stringParameters[..<index1])
            }
            let logmessage = " \(dateString) \(method) \(uRLString)\n[Headers]\n\(stringDefaultHeaders)\n[Body]\(stringParameters)"
            print(logmessage)
        case .pr2NetworkingLogLevelInfo:
            let logmessage = " \(dateString) \(method) \(uRLString)"
            print(logmessage)
        }
    }

    /// didFinishRequest: Executed after any request (activity indicator & console logger)
    ///   - parameter success:    The request was succesfull?
    ///   - parameter response:   The response object
    ///   - parameter statuscode: statuscode of the request
    private func didFinishRequest(_ success: Bool, _ response: DataResponse<Any>) {
        self.timerRequest.invalidate()

        PR2Common().hideNetworkActivityinStatusBar()

        // network console logger
        var statusCode: Int = 0
        if let httpError = response.result.error {
            statusCode = httpError._code
        } else { //no errors
            statusCode = (response.response?.statusCode)!
        }

        let dateString  = Date().PR2DateFormatterForLog()

        switch self.logLevel {
        case .pr2NetworkingLogLevelOff:
            break
        case .pr2NetworkingLogLevelDebug:
            var dictResponseHeaders: NSDictionary?
            if let httpResponse = response.response {
                dictResponseHeaders = httpResponse.allHeaderFields as NSDictionary
                // prepare dictDefaultHeaders for printing
                var stringResponseHeaders = ""
                for (key, value) in dictResponseHeaders! {
                    stringResponseHeaders += "\(key): \(value)\n"
                }
                let index1 = stringResponseHeaders.index(stringResponseHeaders.endIndex, offsetBy: -1)
                stringResponseHeaders = String(stringResponseHeaders[..<index1])
            }

            var logmessage: String = ""
            if response.result.error != nil {
                if response.result.value != nil {
                    logmessage = "\(dateString) [Error] \(String(describing: response.response?.statusCode)) \(String(describing: response.request!.url))\n[Response Headers]\n\(dictResponseHeaders!)\n[Response Body]\n\(response.result.value!)"
                } else {
                    logmessage = "\(dateString) [Error] \(String(describing: response.response?.statusCode)) \(String(describing: response.request!.url))\n[Response Headers]\n[Response Body]\n"
                }
            } else {
                logmessage = "\(dateString) \(statusCode) \(String(describing: response.request!.url))\n[Response Headers]\n\(dictResponseHeaders!)\n[Response Body]\n\(response.result.value!)"
            }
            print(logmessage)
        case .pr2NetworkingLogLevelInfo, .pr2NetworkingLogLevelError:
            var logmessage: String = ""
            if response.result.error != nil {
                logmessage = "\(dateString) [Error] \(String(describing: response.response?.statusCode)) \(String(describing: response.request!.url))"
            } else {
                logmessage = "\(dateString) \(statusCode) \(String(describing: response.request!.url))"
            }
            print(logmessage)
        }
    }

    // MARK: - Timer (slow internet) method

    /**
     Slow internet reached
     */
    @objc dynamic func timerRequestReached() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: PR2NetworkingNotifications.slowInternet), object: nil)
    }

    // MARK: - misc functions

    /// userAgent: Generates user agent from Info.plist
    /// example: SkyPablo:1.0.1/IOS:9.2/x86_64
    /// - returns: String
    public func userAgent() -> String {
        var userAgent: String = "Unknown"
        if let info = Bundle.main.infoDictionary {
            let executable: AnyObject = info[kCFBundleExecutableKey as String] as AnyObject
            let version: AnyObject = info[kCFBundleVersionKey as String] as AnyObject
            let osmajor: AnyObject = ProcessInfo.processInfo.operatingSystemVersion.majorVersion as AnyObject
            let osminor: AnyObject = ProcessInfo.processInfo.operatingSystemVersion.minorVersion as AnyObject
            let model: AnyObject = hardwareString() as AnyObject

            userAgent = NSMutableString(string: "\(executable):\(version)/IOS:\(osmajor).\(osminor)/\(model)") as String

        }
        return userAgent
    }

    /// hardwareString: Generates phone model (hardware)
    /// - returns: String
    private func hardwareString() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
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

}
