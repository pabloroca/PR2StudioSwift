//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
/// A value that represents either a success or a failure, including an
/// associated value in each case.
public enum Result<Success, Failure: Error> {
    /// A success, storing a `Success` value.
    case success(Success)

    /// A failure, storing a `Failure` value.
    case failure(Failure)

    /// Initialiser for value.
    public init(_ value: Success) {
        self = .success(value)
    }

    /// Initialiser for error.
    public init(_ error: Failure) {
        self = .failure(error)
    }

    /// Returns a new result, mapping any success value using the given
    /// transformation.
    ///
    /// Use this method when you need to transform the value of a `Result`
    /// instance when it represents a success. The following example transforms
    /// the integer success value of a result into a string:
    ///
    ///     func getNextInteger() -> Result<Int, Error> { /* ... */ }
    ///
    ///     let integerResult = getNextInteger()
    ///     // integerResult == .success(5)
    ///     let stringResult = integerResult.map({ String($0) })
    ///     // stringResult == .success("5")
    ///
    /// - Parameter transform: A closure that takes the success value of this
    ///   instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform`
    ///   as the new success value if this instance represents a success.
    public func map<NewSuccess>(
        _ transform: (Success) -> NewSuccess
        ) -> Result<NewSuccess, Failure> {
        switch self {
        case let .success(success):
            return .success(transform(success))
        case let .failure(failure):
            return .failure(failure)
        }
    }

    /// Returns a new result, mapping any failure value using the given
    /// transformation.
    ///
    /// Use this method when you need to transform the value of a `Result`
    /// instance when it represents a failure. The following example transforms
    /// the error value of a result by wrapping it in a custom `Error` type:
    ///
    ///     struct DatedError: Error {
    ///         var error: Error
    ///         var date: Date
    ///
    ///         init(_ error: Error) {
    ///             self.error = error
    ///             self.date = Date()
    ///         }
    ///     }
    ///
    ///     let result: Result<Int, Error> = // ...
    ///     // result == .failure(<error value>)
    ///     let resultWithDatedError = result.mapError({ e in DatedError(e) })
    ///     // result == .failure(DatedError(error: <error value>, date: <date>))
    ///
    /// - Parameter transform: A closure that takes the failure value of the
    ///   instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform`
    ///   as the new failure value if this instance represents a failure.
    public func mapError<NewFailure>(
        _ transform: (Failure) -> NewFailure
        ) -> Result<Success, NewFailure> {
        switch self {
        case let .success(success):
            return .success(success)
        case let .failure(failure):
            return .failure(transform(failure))
        }
    }

    /// Returns a new result, mapping any success value using the given
    /// transformation and unwrapping the produced result.
    ///
    /// - Parameter transform: A closure that takes the success value of the
    ///   instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform`
    ///   as the new failure value if this instance represents a failure.
    public func flatMap<NewSuccess>(
        _ transform: (Success) -> Result<NewSuccess, Failure>
        ) -> Result<NewSuccess, Failure> {
        switch self {
        case let .success(success):
            return transform(success)
        case let .failure(failure):
            return .failure(failure)
        }
    }

    /// Returns a new result, mapping any failure value using the given
    /// transformation and unwrapping the produced result.
    ///
    /// - Parameter transform: A closure that takes the failure value of the
    ///   instance.
    /// - Returns: A `Result` instance, either from the closure or the previous
    ///   `.success`.
    public func flatMapError<NewFailure>(
        _ transform: (Failure) -> Result<Success, NewFailure>
        ) -> Result<Success, NewFailure> {
        switch self {
        case let .success(success):
            return .success(success)
        case let .failure(failure):
            return transform(failure)
        }
    }

    /// Returns the success value as a throwing expression.
    ///
    /// Use this method to retrieve the value of this result if it represents a
    /// success, or to catch the value if it represents a failure.
    ///
    ///     let integerResult: Result<Int, Error> = .success(5)
    ///     do {
    ///         let value = try integerResult.get()
    ///         print("The value is \(value).")
    ///     } catch error {
    ///         print("Error retrieving the value: \(error)")
    ///     }
    ///     // Prints "The value is 5."
    ///
    /// - Returns: The success value, if the instance represents a success.
    /// - Throws: The failure value, if the instance represents a failure.
    public func get() throws -> Success {
        switch self {
        case let .success(success):
            return success
        case let .failure(failure):
            throw failure
        }
    }
}

public struct AnyError: Error, CustomStringConvertible {
    /// The underlying error.
    public let underlyingError: Error

    public init(_ error: Error) {
        // If we already have any error, don't nest it.
        if case let error as AnyError = error {
            self = error
        } else {
            self.underlyingError = error
        }
    }

    public var description: String {
        return String(describing: underlyingError)
    }
}

extension Result: Equatable where Success: Equatable, Failure: Equatable { }

extension Result: Hashable where Success: Hashable, Failure: Hashable { }

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

extension Result: Codable where Success: Codable, Failure: Codable {
    private enum CodingKeys: String, CodingKey {
        case success, failure
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .success(let value):
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .success)
            try unkeyedContainer.encode(value)
        case .failure(let error):
            var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .failure)
            try unkeyedContainer.encode(error)
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = values.allKeys.first(where: values.contains) else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Did not find a matching key"))
        }
        switch key {
        case .success:
            var unkeyedValues = try values.nestedUnkeyedContainer(forKey: key)
            let value = try unkeyedValues.decode(Success.self)
            self = .success(value)
        case .failure:
            var unkeyedValues = try values.nestedUnkeyedContainer(forKey: key)
            let error = try unkeyedValues.decode(Failure.self)
            self = .failure(error)
        }
    }
}
