//
//  RetryConfiguration.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 21/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

enum RetryMode {
    case request
    case session
}

public struct RetryConfiguration {
    /// initial retry delay
    var retryDelay: Double = 1.0  // in seconds
    /// maimum retry delay
    var maximumretryDelay: Double = 15.0  // in seconds

    public init(retryDelay: Double, maximumretryDelay: Double) {
        self.retryDelay = retryDelay
        self.maximumretryDelay = maximumretryDelay
    }
}
