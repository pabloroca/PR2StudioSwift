//
//  ParseToCodableType.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 22/06/2018.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import Foundation

/// Parse data to a Codable Tyoe

private enum ParseToCodableTypeError: Error {
    case somethingWentWrong
}

public final class ParseToCodableType {

    // MARK: - Methods

    public static func asynchronous<TypeTo: Decodable>(toType: TypeTo.Type, key: String, bundle: Bundle? = nil, completion: @escaping (Result<TypeTo, AnyError>) -> Void) {
        if let inputString = ProcessInfo.processInfo.environment[key] ?? Stubs.sharedInstance.resultForMethod[key] {
            ParseToCodableType.fromJSONStringAsync(inputString, toType: toType) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        } else {
            ParseToCodableType.fromJSONFileAsync(key, toType: toType, bundle: bundle) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }

    public static func synchronous<TypeTo: Decodable>(toType: TypeTo.Type, key: String, bundle: Bundle? = nil) -> Result<TypeTo, AnyError> {
        if let inputString = ProcessInfo.processInfo.environment[key] ?? Stubs.sharedInstance.resultForMethod[key] {
            return ParseToCodableType.fromJSONString(inputString, toType: toType)
        } else {
            return ParseToCodableType.fromJSONFile(key, toType: toType, bundle: bundle)
        }
    }

    // MARK: - Private Methods

    public static func fromDictionary<TypeTo: Decodable>(_ dictionary: [String: Any], toType: TypeTo.Type) -> Result<TypeTo, AnyError> {
        // NOTE: we could specialize more the error if PR2Error could be DeCodable
        if (dictionary["PR2Error"] as? [String: Any]) != nil {
            return .failure(AnyError(ParseToCodableTypeError.somethingWentWrong))
        } else {
            guard
                let theJSONData = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
                let typeParsed = try? JSONDecoder().decode(toType.self, from: theJSONData)
                else {
                    return .failure(AnyError(ParseToCodableTypeError.somethingWentWrong))
            }
            return .success(typeParsed)
        }
    }

    private static func asynchronousEnd<TypeTo: Decodable>(dictionary: [String: Any], result: Result<TypeTo, AnyError>, completion: @escaping (Result<TypeTo, AnyError>) -> Void) {
        guard case .success(let typeParsed) = result else {
            completion(result)
            return
        }
        if let delay = dictionary["TPADelay"] as? TimeInterval {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                return completion(.success(typeParsed))
            }
        } else {
            return completion(.success(typeParsed))
        }
    }

    private static func fromJSONFile<TypeTo: Decodable>(_ inputJSONFile: String, toType: TypeTo.Type, bundle: Bundle? = nil) -> Result<TypeTo, AnyError> {
        let dictionary: [String: Any] = JSONHelper.readJSONFileAsDictionary(file: inputJSONFile, bundle: bundle)
        return ParseToCodableType.fromDictionary(dictionary, toType: toType.self)
    }

    private static func fromJSONFileAsync<TypeTo: Decodable>(_ inputJSONFile: String, toType: TypeTo.Type, bundle: Bundle? = nil, completion: @escaping (Result<TypeTo, AnyError>) -> Void) {
        let dictionary: [String: Any] = JSONHelper.readJSONFileAsDictionary(file: inputJSONFile, bundle: bundle)
        let result = ParseToCodableType.fromJSONFile(inputJSONFile, toType: toType.self, bundle: bundle)
        ParseToCodableType.asynchronousEnd(dictionary: dictionary, result: result) { result in
            completion(result)
        }
    }

    private static func fromJSONString<TypeTo: Decodable>(_ inputString: String, toType: TypeTo.Type) -> Result<TypeTo, AnyError> {
        let dictionary: [String: Any] = JSONHelper.convertJSONStringToDictionary(from: inputString)
        return ParseToCodableType.fromDictionary(dictionary, toType: toType.self)
    }

    private static func fromJSONStringAsync<TypeTo: Decodable>(_ inputString: String, toType: TypeTo.Type, completion: @escaping (Result<TypeTo, AnyError>) -> Void) {
        let dictionary: [String: Any] = JSONHelper.convertJSONStringToDictionary(from: inputString)
        let result = ParseToCodableType.fromJSONString(inputString, toType: toType.self)
        ParseToCodableType.asynchronousEnd(dictionary: dictionary, result: result) { result in
            completion(result)
        }
    }

}
