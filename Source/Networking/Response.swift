//
//  Response.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 18/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public struct Response {
    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The data returned by the server.
    public let data: Data?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: NetworkingError?

    public init(data: Data?, response: HTTPURLResponse?, error: NetworkingError?) {
        self.data = data
        self.response = response
        self.error = error
    }
}
