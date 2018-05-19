//
//  String+Extensions.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca Rozas on 19/5/18.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import Foundation

public extension StringProtocol {
    var ascii: [Int] {
        return unicodeScalars.filter {$0.isASCII}.map {Int($0.value)}
    }
}

public extension Character {
    var ascii: Int? {
        return Int(String(self).unicodeScalars.filter {$0.isASCII}.first?.value ?? 0)
    }
}
