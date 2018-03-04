//
//  PR2Dates.swift
//  FashionBrowserPablo
//
//  Created by Pablo Roca Rozas on 27/1/16.
//  Copyright © 2016 PR2Studio. All rights reserved.
//

import Foundation

extension String {

    public func PR2DateFormatterFromWeb() -> Date {
        return DateFormatter.PR2DateFormatterFromWeb.date(from: self)!
    }

    public func PR2DateFormatterFromAPI() -> Date {
        return DateFormatter.PR2DateFormatterFromAPI.date(from: self)!
    }

    public func PR2DateFormatterFromAPIT() -> Date {
        return DateFormatter.PR2DateFormatterFromAPIT.date(from: self)!
    }

    public func PR2DateFormatterYYYYMMDD() -> Date {
        return DateFormatter.PR2DateFormatterYYYYMMDD.date(from: self)!
    }

    public func PR2DateFormatterForHeader() -> Date {
        return DateFormatter.PR2DateFormatterForHeader.date(from: self)!
    }

}

extension Date {

    // Date format for API
    public func PR2DateFormatterFromAPI() -> String {
        return DateFormatter.PR2DateFormatterFromAPI.string(from: self)
    }

    // Date format for APIT
    public func PR2DateFormatterFromAPIT() -> String {
        return DateFormatter.PR2DateFormatterFromAPIT.string(from: self)
    }

    // Date format for Logs
    public func PR2DateFormatterForLog() -> String {
        return DateFormatter.PR2DateFormatterForLog.string(from: self)
    }

    // Date in UTC
    public func PR2DateFormatterUTC() -> String {
        return DateFormatter.PR2DateFormatterUTC.string(from: self)
    }

    // Date in HHMMh
    public func PR2DateFormatterHHMM() -> String {
        return DateFormatter.PR2DateFormatterHHMM.string(from: self)
    }

    // Date in YYYY-MM-DD
    public func PR2DateFormatterYYYYMMDD() -> String {
        return DateFormatter.PR2DateFormatterYYYYMMDD.string(from: self)
    }

    // Date in MMM dd., EEE
    public func PR2DateFormatterForHeader() -> String {
        return DateFormatter.PR2DateFormatterForHeader.string(from: self)
    }

}

extension DateFormatter {

    fileprivate static let PR2DateFormatterFromWeb: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter
    }()

    fileprivate static let PR2DateFormatterFromAPI: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    fileprivate static let PR2DateFormatterFromAPIT: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    fileprivate static let PR2DateFormatterForLog: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    fileprivate static let PR2DateFormatterUTC: DateFormatter = {
        let formatter = DateFormatter()
        let timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = timeZone
        return formatter
    }()

    fileprivate static let PR2DateFormatterHHMM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    fileprivate static let PR2DateFormatterYYYYMMDD: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    fileprivate static let PR2DateFormatterForHeader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd., EEE"
        return formatter
    }()
}
