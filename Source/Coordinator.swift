//
//  Coordinator.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca Rozas on 4/3/18.
//

import UIKit

/// A Coordinator represents a type that connects the flows between viewcontrollers.
/// Responsibilities of a Coordinator could be implementing delegates and closures of UIViewControllers and pushing them on the navigation stack.
///
/// A Coordinator creates its own navigationcontainer, represented by the associatedtype NavigationContainer, which owns the viewcontrollers in the flow.
/// The NavigationContainer could for instance be a UINavigationController, or UITabbarController, or a custom type, etc.
///
/// To prevent the use of singletons, a Coordinator can externally receive a type containing its necessary dependencies. As indicated by the Dependencies associatedtype.
/// These dependencies could be a real/mock network layer, a usersession, localstorage, analytics, error handler etc.
/// By obtaining them from the parent, viewcontrollers don't need to reach for singletons to obtain dependencies, this way we avoid some tight-coupling.
///
/// A Coordinator can also create other Coordinators, allowing for more complex flows.
public protocol Coordinator {

    /// An associatedtype representing the Dependencies that are needed to make this Coordinator work
    associatedtype Dependencies
    /// The depencies could be a type containing all kinds of dependencies, such as a UserSession, a real/mock network layer.
    var dependencies: Dependencies { get set }

    /// The NavigationContainer represents an initial Viewcontroller that holds other viewcontrollers.
    /// Such as a UINavigationController, UITabbarController or something else (e.g. custom vc).
    /// Then the parent can call start(), obtain this UIViewController and decide how to present it.
    associatedtype NavigationContainer: UIViewController // A NavigationContainer associatedtype helps adding context to what kind of UIViewController is expected.

    /// Start should supply the NavigationContainer UIViewController that will contain other viewcontrollers.
    /// The parent must decide how to present this.
    /// E.g. returning a UINavigationController gives the parent the ability to either present it, or put it inside a UITabbarController
    func start() -> NavigationContainer
}
