//
//  UITableView+Extension.swift
//
//  Created by Pablo Roca Rozas on 17/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import UIKit

extension UITableView {

    open func reloadData(fading: Bool) {
        if fading {
            let transition = CATransition()
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            transition.fillMode = kCAFillModeForwards
            transition.duration = 0.2
            layer.add(transition, forKey: "fadeOnReloadAnimation")

            reloadData()
        }
    }

    /// Generic method to dequeue UITableViewCell. Making sure that all force casts are isolated in this extension
    ///
    /// - Parameters:
    ///   - identifier: A string identifying the cell object to be reused.
    ///   - indexPath: The index path specifying the location of the cell.
    /// - Returns: A UITableviewCell instance of an expected type
    open func dequeueReusableCell<T: UITableViewCell>(withIdentifier identifier: String, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }

    /// Registers a cell class for dequeueing. The reuseidentifier will be the class name of the type
    ///
    /// - Parameter type: The cell class to register
    open func registerCellClass<T: UITableViewCell>(ofType type: T.Type) {
        self.register(T.self, forCellReuseIdentifier: self.reuseIdentifierForCellClass(cellClass: type))
    }

    /// Dequeues a cell of a given type. The reuseidentifier used for dequeueing will be the class name.
    ///
    /// - Parameters:
    ///   - type: The type of which a new cell should be dequeued
    ///   - indexPath: The indexpath specifying the location of the cell
    /// - Returns: A UITableViewCell instance of the expected type
    open func dequeueReusableCell<T: UITableViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: self.reuseIdentifierForCellClass(cellClass: type), for: indexPath) as! T
    }

    private func reuseIdentifierForCellClass(cellClass: AnyClass) -> String {
        return String(describing: cellClass.self)
    }

    /// Registers a header/footer class for dequeueing. The reuseidentifier will be the class name of the type
    ///
    /// - Parameter type: The header/footer class to register
    open func registerHeaderFooterClass<T: UITableViewHeaderFooterView>(ofType type: T.Type) {
        self.register(T.self, forHeaderFooterViewReuseIdentifier: self.reuseIdentifierForHeaderFooterClass(headerFooterClass: type))
    }

    /// Dequeues a header/footer of a given type. The reuseidentifier used for dequeueing will be the class name.
    ///
    /// - Parameters:
    ///   - type: The type of which a new header/footer should be dequeued
    /// - Returns: A UITableViewHeaderFooterView instance of the expected type
    open func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(ofType type: T.Type) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: self.reuseIdentifierForHeaderFooterClass(headerFooterClass: type))
    }

    private func reuseIdentifierForHeaderFooterClass(headerFooterClass: AnyClass) -> String {
        return String(describing: headerFooterClass.self)
    }

    /// Generic method to dequeue UITableViewHeaderFooterView. Making sure that all force casts are isolated in this extension
    ///
    /// - Parameter identifier: A string identifying the header object to be reused.
    /// - Returns: A UITableViewHeaderFooterView instance of an expected type
    open func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withIdentifier identifier: String) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: identifier) as! T
    }

    //set the tableHeaderView so that the required height can be determined, update the header's frame and set it again
    open func layoutHeaderView() {
        if let tableHeader = tableHeaderView {
            tableHeader.setNeedsLayout()
            tableHeader.layoutIfNeeded()
            let maxSize = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
            let size = tableHeader.systemLayoutSizeFitting(maxSize)
            let height = size.height
            var headerFrame = tableHeader.frame

            // If we don't have this check, viewDidLayoutSubviews() will get
            // repeatedly, causing the app to hang.
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                tableHeader.frame = headerFrame
                tableHeaderView = tableHeader
            }
        }
    }

}
