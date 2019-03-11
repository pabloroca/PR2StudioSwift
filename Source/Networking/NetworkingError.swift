//
//  NetworkingError.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 07/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public enum NetworkingError: Error {
    case buildRequestError(underlyingError: BuildRequestError)
    case dataTaskError(underlyingError: DataTaskError, statuscode: Int)
    case authorizationError(underlyingError: AuthorizationError)
    case parsingFailure(underlyingError: ParsingError)
    case genericError(underlyingError: Error)
}

public enum BuildRequestError: String, Error {
    case encodingFailed = "Parameter encoding failed."
}

public enum AuthorizationError: String, Error {
    case noauthorizationdefined = "No Authorization type defined."
    case authorizationFailed = "Authorization failed."
    case authorizationHandlingFailed = "Authorization handling failed."
}

public enum DataTaskError: String, Error {
    case responseFailed = "Getting response failed."
    case tooManyAttempts = "Too many attempts."
}

public enum ParsingError: String, Error {
    case noData = "No data in response."
    case jsonparsingFailed = "JSON parsing failed."
    case dataparsingFailed = "Data parsing failed."
    case parsingFailed = "Parsing failed."
}
