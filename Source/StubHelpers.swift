//
//  StubHelpers.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 11/07/2018.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import Foundation

// MARK: - Singleton for Unit Tests.

/// Singleton who contains stubbed results to override the default JSON results
public final class Stubs {
    static let sharedInstance = Stubs()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    // a dictionary of method name and a string with the stubbed result
    var resultForMethod: [String: String] = [:]
}
