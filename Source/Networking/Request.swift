//
//  Request.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 07/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public enum ParameterEncoding {
    case url
    case json
}

public extension URLRequest {

    // MARK: - properties
    /// Error if any
    private static var _networkingError = [String: NetworkingError?]()
    public var error: NetworkingError? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return URLRequest._networkingError[tmpAddress] ?? nil
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            URLRequest._networkingError[tmpAddress] = newValue
        }
    }

    /// Request id
    private static var _id = [String: String]()
    public var id: String {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return URLRequest._id[tmpAddress] ?? ""
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            URLRequest._id[tmpAddress] = newValue
        }
    }

    /// Request retryConfiguration
    private static var _retryConfiguration = [String: RetryConfiguration?]()
    public var retryConfiguration: RetryConfiguration? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return URLRequest._retryConfiguration[tmpAddress] ?? nil
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            URLRequest._retryConfiguration[tmpAddress] = newValue
        }
    }

    // MARK: - methods

    /// Builds a request
    ///
    /// - Parameters:
    ///   - url: url (String)
    ///   - method: method to call (HTTPMethod)
    ///   - parameters: queryString parameters [String: Any]?
    ///   - encoding: parameters encoding (defaults to json and body)
    ///   - headers: headers [String: String]?
    ///   - bearerToken: Auth bearer token String?
    public init?(_ url: String, method: HTTPMethod = .get, parameters: [String: Any]? = nil, encoding: ParameterEncoding? = .url, headers: [String: String]? = nil, retryConfiguration: RetryConfiguration? = nil, bearerToken: String? = nil) {
        guard let url = URL(string: url) else {
            return nil
        }
        self.init(url: url)
        self.httpMethod = method.rawValue
        self.allHTTPHeaderFields = headers
        self.id = UUID().uuidString
        self.retryConfiguration = retryConfiguration
        if let parameters = parameters as? [String: String], let encoding = encoding {
            do {
                if encoding == .url {
                    let queryParams = parameters.map { pair  in
                        return URLQueryItem(name: pair.key, value: pair.value)
                    }
                    guard var components = URLComponents(string: url.absoluteString) else {
                        return nil
                    }
                    components.queryItems = queryParams
                    self.url = components.url
                    if self.value(forHTTPHeaderField: "Content-Type") == nil {
                        self.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                    }
                } else {
                    let body = try JSONEncoder().encode(parameters)
                    self.httpBody = body
                    if self.value(forHTTPHeaderField: "Content-Type") == nil {
                        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
                }
                guard let bearerToken = bearerToken else {
                    return
                }
                setBearerToken(bearerToken)
            } catch {
                self.error = NetworkingError.buildRequestError(underlyingError: .encodingFailed)
            }
        } else {
            guard let bearerToken = bearerToken else {
                return
            }
            setBearerToken(bearerToken)
        }
    }

    /// Creates a Bearer token in the headers
    ///
    /// - Parameter bearerToken: bearer Token
    public mutating func setBearerToken(_ bearerToken: String) {
        self.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
    }
}
