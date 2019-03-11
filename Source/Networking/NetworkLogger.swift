//
//  NetworkLogger.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 18/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

/// Networking log levels
public enum NetworkLoggerLogLevel {
    case networkLoggerLogLevelOff
    case networkLoggerLogLevelDebug
    case networkLoggerLogLevelInfo
    case networkLoggerLogLevelError
}

public class NetworkLogger {

    /// Networking log levels
    public var logLevel: NetworkLoggerLogLevel

    public init(logLevel: NetworkLoggerLogLevel) {
        self.logLevel = logLevel
    }

    func willStartRequest(_ request: URLRequest) {
        let dateString = Date().PR2DateFormatterForLog()

        guard let httpMethod = request.httpMethod,
            let url = request.url
            else {
                return
        }

        switch logLevel {
        case .networkLoggerLogLevelOff:
            break
        case .networkLoggerLogLevelDebug:
            let logmessage = "\(dateString) \(httpMethod) \(url)"
            print(logmessage)
            print("id=\(request.id)")
            print("Request Headers: ")
            if let allHTTPHeaderFields = request.allHTTPHeaderFields {
                for header in allHTTPHeaderFields {
                    print("\(header.key): \"\(header.value)\"")
                }
            }
            if let httpBody = request.httpBody {
                print("Request Body: ")
                let bodyString = String(decoding: httpBody, as: UTF8.self)
                print("\(bodyString)")
            }
        case .networkLoggerLogLevelInfo:
            let logmessage = "\(dateString) \(httpMethod) \(url)"
            print(logmessage)
            print("id=\(request.id)")
        case .networkLoggerLogLevelError:
            break
        }
    }

    func didFinishRequest<ToType: Decodable>(_ request: URLRequest, response: HTTPURLResponse?, parserType: NetworkParserType, toType: ToType.Type, data: Data?) {
        let dateString = Date().PR2DateFormatterForLog()

        guard let httpMethod = request.httpMethod,
            let url = request.url
            else {
                return
        }

        if logLevel != .networkLoggerLogLevelOff {
            let logmessage = "\(dateString) \(httpMethod) \(url) Response"
            print(logmessage)
            print("id=\(request.id)")
        }

        guard let response = response else {
            return
        }

        switch logLevel {
        case .networkLoggerLogLevelOff:
            break
        case .networkLoggerLogLevelDebug:
            print("status \(response.statusCode)")
            guard let headers = response.allHeaderFields as NSDictionary? as! [String: String]? else {
                return
            }
            print("Response Headers: ")
            for header in headers {
                print("\(header.key): \"\(header.value)\"")
            }
            print("Response Body: ")
            guard let data = data else {
                return
            }

            do {
                guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    return
                }
                print(String(data: try! JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted), encoding: .utf8 )!)
            } catch {
                let parser = NetworkParser(parserType: parserType, toType: toType, data: data)
                if case let .success(value) = parser.result {
                    print(value)
                }
                return
            }

        case .networkLoggerLogLevelInfo:
            print("status \(response.statusCode)")
        case .networkLoggerLogLevelError:
            print("status \(response.statusCode)")
        }
    }
}
