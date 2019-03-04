//
//  AuthorizationJWT.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 28/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public final class AuthorizationJWT: Authorization {

    public private(set) var authEndPoint: String
    public private(set) var parameters: [String: String]

    public init(authEndPoint: String, parameters: [String: String]) {
        self.authEndPoint = authEndPoint
        self.parameters = parameters
    }

    public func authorize(completionHandler: @escaping (Result<Any, AnyError>) -> Void) {
        let requestOptional = URLRequest(authEndPoint, method: .post, parameters: parameters, encoding: .json)
        guard let request = requestOptional else {
            completionHandler(.failure(AnyError(
                NetworkingError.authorizationError(underlyingError: .authorizationHandlingFailed))))
            return
        }

        NetworkSession.shared.dataTask(request, parserType: .data, toType: String.self, authorization: nil) { (result) in
            if case let .success(value) = result {
                guard let token = value as? String else {
                    completionHandler(.failure(AnyError(
                        NetworkingError.authorizationError(underlyingError: .authorizationHandlingFailed))))
                    return
                }
                if !KeyChainService.save(token, forKey: "jwt") {
                    completionHandler(.failure(AnyError(
                        NetworkingError.authorizationError(underlyingError: .authorizationHandlingFailed))))
                } else {
                    completionHandler(result)
                }
            } else {
                completionHandler(result)
            }
        }
    }

}
