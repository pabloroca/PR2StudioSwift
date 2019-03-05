//
//  Authorization.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 28/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public protocol Authorization: AnyObject {
    var authEndPoint: String { get }
    var parameters: [String: String] { get }
    func loadCredentials() -> String
    func authorize(completionHandler: @escaping (_ result: Result<Any, AnyError>) -> Void)
}
