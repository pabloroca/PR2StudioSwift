//
//  Coordinator.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca Rozas on 4/3/18.
//  Copyright © 2018 PR2Studio. All rights reserved.
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
    /// The parent can decide how to present this.
    /// E.g. returning a UINavigationController gives the parent the ability to either present it, or put it inside a UITabbarController
    func start() -> NavigationContainer
}

// MARK: - Type erasing Coordinator

/// AnyCoordinator is a type-erased Coordinator. Because Coordinator has associatedtypes, sooner or later you may need to type erase.
/// For instance, if you want to store Coordinators in an array, or when you want to keep one in a property such as let currentCoordinator: AnyCoordinator.
///
/// The benefit is that you can then store this Coordinator protocol inside arrays, properties etc. Just like a protocol without an associatedtype.
///
/// You can wrap a Coordinator inside an AnyCoordinator, then you can store it inside a property or dictionary, array etc.
///
/// Example usage:
///
///         var currentCoordinator: AnyCoordinator<MyDependencies, UINavigationController = AnyCoordinator(EnrollmentCoordinator())
///
/// As long as the two associated types match (Dependencies and NavigationContainer), then your coordinator fits inside an AnyCoordinator
public final class AnyCoordinator<Dependencies, NavigationContainer: UIViewController>: Coordinator {
    private let box: _AnyCoordinatorBase<Dependencies, NavigationContainer>

    public var dependencies: Dependencies {
        get {
            return box.dependencies
        } set {
            box.dependencies = newValue
        }
    }

    // Initializer takes our concrete implementer of Coordinator
    public init<Concrete: Coordinator>(_ concrete: Concrete)
        where Concrete.Dependencies == Dependencies,
        Concrete.NavigationContainer == NavigationContainer {
            box = _AnyCoordinatorBox(concrete)
    }

    public func start() -> NavigationContainer {
        return box.start()
    }

}

// Type erasing Coordinator Protocol (Coordinator is a Protocol with associated type (PAT) and we want dynamic usage).

private final class _AnyCoordinatorBox<Concrete: Coordinator>: _AnyCoordinatorBase<Concrete.Dependencies, Concrete.NavigationContainer> {
    // variable used since we're calling mutating functions
    var concrete: Concrete

    override var dependencies: Dependencies {
        get {
            return concrete.dependencies
        } set {
            concrete.dependencies = newValue
        }
    }

    init(_ concrete: Concrete) {
        self.concrete = concrete
        super.init()
    }

    override func start() -> NavigationContainer {
        return concrete.start()
    }

}

private class _AnyCoordinatorBase<Dependencies, NavigationContainer: UIViewController>: Coordinator {

    var dependencies: Dependencies {
        get {
            fatalError("Must override")
        } set {
            fatalError("Must override")
        }
    }

    init() {
        guard type(of: self) != _AnyCoordinatorBase.self else {
            fatalError("_AnyCoordinatorBase instances can not be created; create a subclass instance instead")
        }
    }

    func start() -> NavigationContainer {
        fatalError("_AnyCoordinatorBase start not be called; create a subclass instance instead")
    }

}
