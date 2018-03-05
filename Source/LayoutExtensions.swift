//
//  LayoutExtensions.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca Rozas on 3/3/18.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import UIKit

extension UIView {
    /// Adds the child view, sets autoresizing mask to false and activates constraints
    ///
    /// - Parameters:
    ///   - child: child view
    ///   - constraints: array of constraints
    public func addSubview(_ child: UIView, constraints: [NSLayoutConstraint]) {
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}

extension UIStackView {
    /// Adds the child view, sets autoresizing mask to false and activates constraints
    ///
    /// - Parameters:
    ///   - child: child view
    ///   - constraints: array of constraints
    public func addArrangedSubview(_ child: UIView, constraints: [NSLayoutConstraint]) {
        addArrangedSubview(child)
        NSLayoutConstraint.activate(constraints)
    }
}

// based in https://www.innoq.com/en/blog/ios-auto-layout-problem/
extension NSLayoutConstraint {
    /// Convenience method that activates each constraint in the contained array, in the same manner as setting active=YES. This is often more efficient than activating each constraint individually.
    ///
    /// - Parameter consviewWaitingtraints: array of constraints
    public class func activateAndAutoresizingMask(_ constraints: [NSLayoutConstraint]) {
        let views = constraints.flatMap { $0.firstItem as? UIView }
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        activate(constraints)
    }
}
