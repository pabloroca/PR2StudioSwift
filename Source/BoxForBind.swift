//
//  BoxForBind.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 2018.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import Foundation

class BoxForBind<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?

    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
