//
//  PR2Common.swift
//
//  Created by Pablo Roca Rozas on 24/1/16.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

// Common functions for any project

import Foundation
import UIKit

#if os(iOS)
import CoreTelephony
#endif

/**
 Swift equivalence of @synchronized in ObjectiveC until a native language alternative comes around.
 */
@discardableResult
public func synchronized<T>(_ object: Any, closure: () throws -> T) rethrows -> T {
    objc_sync_enter(object)
    defer {
        objc_sync_exit(object)
    }
    return try closure()
}

/// Commom functions for any project
open class PR2Common {

    public init() { }

    /**
     Displays network activity indicator in status bar
     */
    open func showNetworkActivityinStatusBar() {
        #if UIApplication
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        #endif
    }
    /**
     Hides network activity indicator in status bar
     */
    open func hideNetworkActivityinStatusBar() {
        #if UIApplication
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        #endif
    }

    #if os(iOS)
    open var topMostVC: UIViewController? {
        #if UIApplication
        var presentedVC = UIApplication.shared.keyWindow?.rootViewController
        while let pVC = presentedVC?.presentedViewController {
            presentedVC = pVC
        }

        if presentedVC == nil {
            print("Error: You don't have any views set. You may be calling them in viewDidLoad. Try viewDidAppear instead.")
        }
        return presentedVC
        #else
        return nil
        #endif
    }

    /**
     Simple alert view
     
     - parameter title: title of the alert.
     - parameter message: message to show in the alert.
     */
    open func simpleAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        if let rootViewController = self.topMostVC {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }

    open func canDevicePlaceAPhoneCall() -> Bool {
        #if UIApplication
        if UIApplication.shared.canOpenURL(NSURL(string: "tel://")! as URL) {
            let netInfo = CTTelephonyNetworkInfo()
            let carrier = netInfo.subscriberCellularProvider
            let mnc = carrier?.mobileNetworkCode
            if (mnc?.characters == nil || mnc! == "65535") {
                // Device cannot place a call at this time.  SIM might be removed.
                return false
            } else {
                // Device can place a phone call
                return true
            }
        } else {
            return false
        }
        #else
        return false
        #endif
    }
    #endif

    open func readJSONFileAsDict(file: String) -> [String: Any] {
        do {
            if let path = Bundle.main.path(forResource: file, ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    return object
                } else {
                    return [:]
                }
            } else {
                return [:]
            }
        } catch {
            return [:]
        }
    }

    open func readJSONFileAsArray(file: String) -> [Any] {
        do {
            if let path = Bundle.main.path(forResource: file, ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [Any] {
                    // json is an array
                    return object
                } else {
                    return []
                }
            } else {
                return []
            }
        } catch {
            return []
        }
    }

    open func documentsDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return documentsFolderPath
    }

    // File in Documents directory
    open func fileInDocumentsDirectory(filename: String) -> String {
        return documentsDirectory().stringByAppendingPathComponent(path: filename)
    }

    // MARK: - Regex

    /// checks if text matches regex pattern
    open func regex(text: String?, regex: String?) -> Bool {
        guard let text = text, let regex = regex else {
            return false
        }
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                        options: [],
                                        range: NSRange(location: 0, length: nsString.length))
            return (results.isEmpty ? false : true)
        } catch _ as NSError {
            return false
        }
    }

    // extracts regex matches in an array
    // from http://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    //
    open func matchesForRegexInText(text: String?, regex: String?) -> [String] {
        guard let text = text, let regex = regex else {
            return []
        }

        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                        options: [],
                                        range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch _ as NSError {
            return []
        }
    }

    open func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
}
