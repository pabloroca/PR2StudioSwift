//
//  NetworkParser.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 25/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public struct NetworkParser<ToType: Decodable> {
    public var result: Result<Any, AnyError>

    public init(parserType: NetworkParserType, toType: ToType.Type, data: Data?) {
        guard let data = data else {
            self.result = .failure(AnyError(NetworkingError.parsingFailure(underlyingError: .noData)))
            return
        }

        switch parserType {
        case .json:
            do {
                guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    self.result = .failure(AnyError(NetworkingError.parsingFailure(underlyingError: .jsonparsingFailed)))
                    return
                }
                let result = ParseToCodableType.fromDictionary(jsonDictionary, toType: toType)
                if case let .success(value) = result {
                    self.result = .success(value)
                } else {
                    self.result = .failure(AnyError(NetworkingError.parsingFailure(underlyingError: .jsonparsingFailed)))
                }
            } catch {
                self.result = .failure(AnyError(NetworkingError.parsingFailure(underlyingError: .jsonparsingFailed)))
            }
        case .data:
            print("data")
            self.result = .success("")
        }

    }

}
