//
//  JSONHelper.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 13/06/2018.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import Foundation

/// Parse JSON fron file in bundle
public final class JSONHelper {

    /// Parse JSON file
    ///
    /// - Parameters:
    ///   - file: file name (with no extension)
    ///   - bundle: bundle
    /// - Returns: JSON data as Dictionary [String: Any]
    public static func readJSONFileAsDictionary(file: String, bundle: Bundle? = nil) -> [String: Any] {

        let bundleToUse = bundle ?? Bundle(for: self)
        guard
            let jsonFileURL = bundleToUse.path(forResource: file, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: jsonFileURL), options: .alwaysMapped),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let dictionaryParsed = dictionary
            else {
                return [:]
        }
        return dictionaryParsed
    }

    /// Reads a JSON file to a String
    ///
    /// - Parameters:
    ///   - file: file name (with no extension)
    ///   - bundle: bundle
    /// - Returns: JSON data as String
    public static func readJSONFileAsString(file: String, bundle: Bundle? = nil) -> String {

        let bundleToUse = bundle ?? Bundle(for: self)
        guard let jsonFileURL = bundleToUse.path(forResource: file, ofType: "json") else {
            return ""
        }
        do {
            let contents = try String(contentsOfFile: jsonFileURL)
            return contents
        } catch {
            return ""
        }
    }

    /// Converts a JSON String to a dictionary [String: Any]
    ///
    /// - Parameter text: JSON String
    /// - Returns: Dictionary [String: Any]
    public static func convertJSONStringToDictionary(from text: String) -> [String: Any] {
        guard let data = text.data(using: .utf8) else {
            return [:]
        }
        let anyResult = try? JSONSerialization.jsonObject(with: data, options: []) as Any
        return anyResult as? [String: Any] ?? [:]
    }

}
