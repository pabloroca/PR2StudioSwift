//
//  Version.swift
//  PR2StudioSampleApp
//
//  Created by Pablo Roca on 04/03/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import Foundation

public struct Version: Decodable {
    let id: Int
    let tablename: String
    let version: Int

    public init(id: Int, tablename: String, version: Int) {
        self.id = id
        self.tablename = tablename
        self.version = version
    }
}
