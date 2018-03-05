//
//  UITableViewExtensions.swift
//
//  Created by Pablo Roca Rozas on 17/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import UIKit

extension UITableView {

    // MARK: - Elegant load animation

    public func reloadData(fading: Bool) {
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

    // MARK: - register & dequeue Cells

    /// Gets the identifier for a cell class
    ///
    /// - Parameter cellClass: Cell Class (AnyClass)
    /// - Returns: identifier as String
    private func reuseIdentifierForCellClass(cellClass: AnyClass) -> String {
        return String(describing: cellClass.self)
    }

    /// Registers a cell class for dequeueing. The reuseidentifier will be the class name of the type
    ///
    /// - Parameter type: The cell class to register
    public func registerCellClass<T: UITableViewCell>(ofType type: T.Type) {
        self.register(T.self, forCellReuseIdentifier: self.reuseIdentifierForCellClass(cellClass: type))
    }

    /// Generic method to dequeue UITableViewCell. Making sure that all force casts are isolated in this extension
    ///
    /// - Parameters:
    ///   - identifier: A string identifying the cell object to be reused.
    ///   - indexPath: The index path specifying the location of the cell.
    /// - Returns: A UITableviewCell instance of an expected type
    public func dequeueReusableCell<T: UITableViewCell>(withIdentifier identifier: String, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }

    /// Dequeues a cell of a given type. The reuseidentifier used for dequeueing will be the class name.
    ///
    /// - Parameters:
    ///   - type: The type of which a new cell should be dequeued
    ///   - indexPath: The indexpath specifying the location of the cell
    /// - Returns: A UITableViewCell instance of the expected type
    public func dequeueReusableCell<T: UITableViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: self.reuseIdentifierForCellClass(cellClass: type), for: indexPath) as! T
    }

    // MARK: - register & dequeue header/footer Cells

    /// Gets the identifier for a Header Footer cell class
    ///
    /// - Parameter headerFooterClass: header Footer Class (AnyClass)
    /// - Returns: identifier as String
    private func reuseIdentifierForHeaderFooterClass(headerFooterClass: AnyClass) -> String {
        return String(describing: headerFooterClass.self)
    }

    /// Registers a header/footer class for dequeueing. The reuseidentifier will be the class name of the type
    ///
    /// - Parameter type: The header/footer class to register
    public func registerHeaderFooterClass<T: UITableViewHeaderFooterView>(ofType type: T.Type) {
        self.register(T.self, forHeaderFooterViewReuseIdentifier: self.reuseIdentifierForHeaderFooterClass(headerFooterClass: type))
    }

    /// Generic method to dequeue UITableViewHeaderFooterView. Making sure that all force casts are isolated in this extension
    ///
    /// - Parameter identifier: A string identifying the header object to be reused.
    /// - Returns: A UITableViewHeaderFooterView instance of an expected type
    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withIdentifier identifier: String) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: identifier) as! T
    }

    /// Dequeues a header/footer of a given type. The reuseidentifier used for dequeueing will be the class name.
    ///
    /// - Parameter type: The type of which a new header/footer should be dequeued
    /// - Returns: A UITableViewHeaderFooterView instance of the expected type
    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(ofType type: T.Type) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: self.reuseIdentifierForHeaderFooterClass(headerFooterClass: type))
    }

}