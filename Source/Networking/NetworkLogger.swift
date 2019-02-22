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
    case NetworkLoggerLogLevelOff
    case NetworkLoggerLogLevelDebug
    case NetworkLoggerLogLevelInfo
    case NetworkLoggerLogLevelError
}

public class NetworkLogger {

    /// Networking log levels
    public var logLevel: NetworkLoggerLogLevel

    init(logLevel: NetworkLoggerLogLevel) {
        self.logLevel = logLevel
    }

    func willStartRequest() {
    }

    func didFinishRequest() {
    }
}
