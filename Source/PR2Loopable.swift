//
//  PR2Loopable.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 7/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import Foundation

// MARK: - Loopable protocol
/// Loopable protocol
public protocol Loopable: CustomStringConvertible {

    /// Returns all object properties in a dictionary
    ///
    /// - Returns: dictionary of properties
    /// - Throws: when object is not a class or struct
    func allProperties() throws -> [String: AnyObject]
}

// Extension for Loopable
extension Loopable {

    /// Returns all object properties in a dictionary
    ///
    /// - Returns: dictionary of properties
    /// - Throws: when object is not a class or struct
    public func allProperties() throws -> [String: AnyObject] {
        var result: [String: AnyObject] = [:]
        let selfMirror = Mirror(reflecting: self)

        // Optional check to make sure we're iterating over a struct or class
        guard let style = selfMirror.displayStyle, style == .struct || style == .class else {
            throw NSError()
        }

        for (property, value) in selfMirror.children {
            guard let property = property else {
                continue
            }
            result[property] = value as AnyObject
        }
        return result
    }

    public func retrieveInputDictionary() -> [String: AnyObject] {
        var result: [String: AnyObject] = [String: AnyObject]()

        do {
            result = try allProperties()
        } catch _ {
            result = [:]
        }
        return result
    }

    /// Returns all the properties in the description (conforms to CustomStringConvertible)
    public var description: String {
        do {
            let allProperties = try self.allProperties()
            return "("+String(describing: type(of: self))+") " +
                "<\(UnsafeMutableRawPointer(Unmanaged.passUnretained(self as AnyObject).toOpaque()))>\n" +
                (allProperties.flatMap({"\($0): \($1)"}) as Array).joined(separator: "\n")
        } catch {
            return ""
        }
    }
}
