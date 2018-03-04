//
//  PRExtensions.swift
//
//  Created by Pablo Roca Rozas on 3/2/16.
//  Copyright © 2016 PR2Studio. All rights reserved.
//

import Foundation

import UIKit

extension String {
    public func stringByAppendingPathComponent(path: String) -> String {
       let nsSt = self as NSString
       return nsSt.appendingPathComponent(path)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255

        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

#if os(iOS)
extension UIScrollView {
   open func scrollToBottom(animated: Bool) {
      let rect = CGRect(x: 0, y: contentSize.height - bounds.size.height, width: bounds.size.width, height: bounds.size.height)
      scrollRectToVisible(rect, animated: animated)
   }
}
#endif

extension OperationQueue {
    open func addOperationAfterLast(_ operation: Operation) {
        if self.maxConcurrentOperationCount != 1 {
            self.maxConcurrentOperationCount = 1
        }

        let lastOp = self.operations.last
        if let lastOp = lastOp {
            operation.addDependency(lastOp)
        }
        self.addOperation(operation)
    }
}

extension Double {
    public func toPriceString(decimalDigits: Int, currencySymbol: String, thousandsSeparator: String, decimalSeparator: String, symbolOnLeft: Bool = true, spaceBetweenAmountAndSymbol: Bool = false) -> String {

        let numformat: NumberFormatter = NumberFormatter()
        numformat.numberStyle = .decimal
        numformat.alwaysShowsDecimalSeparator = false
        numformat.decimalSeparator = decimalSeparator
        numformat.minimumFractionDigits = 0
        numformat.maximumFractionDigits = decimalDigits

        let spacing = spaceBetweenAmountAndSymbol ? " " : ""
        let number = NSNumber(value: self)
        let numberFormatted = numformat.string(from: number) ?? ""
        return symbolOnLeft ? currencySymbol+spacing+numberFormatted : numberFormatted+spacing+currencySymbol
    }
}
