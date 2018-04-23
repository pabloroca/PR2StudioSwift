//
//  UICollectionView+Extensions.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca on 23/04/2018.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import UIKit

public extension UICollectionView {

    /// Gets the identifier for a cell class
    ///
    /// - Parameter cellClass: Cell Class (AnyClass)
    /// - Returns: identifier as String
    private func reuseIdentifierForCellClass(cellClass: AnyClass) -> String {
        return String(describing: cellClass.self)
    }

    // MARK: - register & dequeue Cells

    /// Registers a cell class for dequeueing. The reuseidentifier will be the class name of the type
    ///
    /// - Parameter type: The cell class to register
    func registerCellClass<T: UICollectionViewCell>(ofType type: T.Type) {
        self.register(T.self, forCellWithReuseIdentifier: self.reuseIdentifierForCellClass(cellClass: type))
    }

    /// Generic method to dequeue UICollectionViewCell. Making sure that all force casts are isolated in this extension
    ///
    /// - Parameters:
    ///   - identifier: A string identifying the cell object to be reused.
    ///   - indexPath: The index path specifying the location of the cell.
    /// - Returns: A UICollectionViewCell instance of an expected type
    func dequeueReusableCell<T: UICollectionViewCell>(withIdentifier identifier: String, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Expected cell \(identifier) at index \(indexPath)")
        }
        return cell
    }

    /// Dequeues a cell of a given type. The reuseidentifier used for dequeueing will be the class name.
    ///
    /// - Parameters:
    ///   - type: The type of which a new cell should be dequeued
    ///   - indexPath: The indexpath specifying the location of the cell
    /// - Returns: A UICollectionViewCell instance of the expected type
    func dequeueReusableCell<T: UICollectionViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: self.reuseIdentifierForCellClass(cellClass: type), for: indexPath) as? T else {
            fatalError("Expected cell \(self.reuseIdentifierForCellClass(cellClass: type)) at index \(indexPath)")
        }
        return cell
    }

}
