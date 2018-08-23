//
//  NavigationCoordinator.swift
//  Coordinated tvOS
//
//  Created by Kristian Andersen on 23/08/2018.
//  Copyright © 2018 Kristian Andersen. All rights reserved.
//

import Foundation
import UIKit

open class NavigationCoordinator: NSObject, Coordinator {
    public var children = [Coordinator]()

    public var rootViewController: UIViewController {
        return navigationController
    }

    public var topCoordinator: Coordinator? {
        return navigationController.topViewController.flatMap(coordinator(for:))
    }

    public var visibleCoordinator: Coordinator? {
        return navigationController.visibleViewController.flatMap(coordinator(for:))
    }

    public var coordinators: [Coordinator] {
        return navigationController.viewControllers.compactMap(coordinator(for:))
    }

    public let navigationController = UINavigationController()

    public convenience init(rootCoordinator: Coordinator) {
        self.init()

        push(coordinator: rootCoordinator, animated: false)
    }

    public func start() {
        navigationController.delegate = self
    }

    public func push(coordinator: Coordinator, animated: Bool = true) {
        add(child: coordinator)
        navigationController.pushViewController(coordinator.rootViewController, animated: animated)

        coordinator.start()
    }
}

extension NavigationCoordinator: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow _: UIViewController,
                                     animated _: Bool) {
        guard let from = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(from) else { return }

        for poppedCoordinator in children.filter({ $0.rootViewController == from }) {
            remove(child: poppedCoordinator)
        }
    }
}
