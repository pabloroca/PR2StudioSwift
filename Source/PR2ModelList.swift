//
//  PR2ModelList.swift
//
//  Created by Pablo Roca Rozas on 8/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import Foundation

open class PR2ModelList<T> {

    open var rows: [T] = []

    init() {}

    open func numberOfRowsInSection(section: Int) -> Int {
        return rows.count
    }

    open func numberOfRows() -> Int {
        return rows.count
    }

    open func readData(completion: @escaping (Bool) -> Void) {
    }

}
