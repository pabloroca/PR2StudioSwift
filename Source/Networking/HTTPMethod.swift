//
//  HTTPMethod.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 07/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case connect = "CONNECT"
    case delete  = "DELETE"
    case get     = "GET"
    case head    = "HEAD"
    case options = "OPTIONS"
    case patch   = "PATCH"
    case post    = "POST"
    case put     = "PUT"
    case trace   = "TRACE"
}
