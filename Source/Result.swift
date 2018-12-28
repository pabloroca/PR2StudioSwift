//
//  Result.swift
//
//  Created by Pablo Roca Rozas on 3/2/16.
//  Copyright © 2016 PR2Studio. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Swift.Error)

    // Allow optional transforms (chaining).
    public func map<TransformedElement>(_ transform: (Value) throws -> TransformedElement) rethrows -> Result<TransformedElement> {
        switch self {
        case .success(let val):
            return Result<TransformedElement>.success(try transform(val))
        case .failure(let error):
            return Result<TransformedElement>.failure(error)
        }
    }

}

extension Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case .success(let value):
            return "Result(\(value))"
        case .failure(let error):
            return "Result(\(error))"
        }
    }
}
