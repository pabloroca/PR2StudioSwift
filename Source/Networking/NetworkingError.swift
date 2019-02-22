//
//  NetworkingError.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 07/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public enum NetworkingError: Error {
    case dataTaskError(underlyingError: DataTaskError)
    case buildRequestError(underlyingError: BuildRequestError)
    case genericError(underlyingError: Error)
}

public enum BuildRequestError: String, Error {
    case encodingFailed = "Parameter encoding failed."
}

public enum DataTaskError: String, Error {
    case responseFailed = "Getting response failed."
}
