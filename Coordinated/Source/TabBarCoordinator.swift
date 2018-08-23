//
//  TabBarCoordinator.swift
//  Coordinated tvOS
//
//  Created by Kristian Andersen on 23/08/2018.
//  Copyright © 2018 Kristian Andersen. All rights reserved.
//

import Foundation
import UIKit

open class TabBarCoordinator: NSObject, Coordinator {
    public var children = [Coordinator]()

    public var rootViewController: UIViewController {
        return tabBarController
    }

    open var tabBarController: UITabBarController = {
        UITabBarController()
    }()

    /// The coordinator associated with the currently selected index
    /// of the tab bar.
    public var selected: Coordinator? {
        let selected = tabBarController.selectedIndex
        guard children.indices.contains(selected) else {
            return nil
        }

        return children[selected]
    }

    public func start() {
        tabBarController.delegate = self
    }

    /// Remove all existing coordinators and insert a new coordinator
    public func set(coordinator: Coordinator, animated: Bool = true) {
        set(coordinators: [coordinator], animated: animated)
    }

    public func set(coordinators: [Coordinator], animated: Bool = true) {
        let existing = tabBarController.viewControllers?.compactMap(coordinator(for:))
        existing?.forEach(remove)

        add(children: coordinators)
        let viewControllers = coordinators.map({ $0.rootViewController })
        tabBarController.setViewControllers(viewControllers, animated: animated)

        coordinators.forEach({ $0.start() })

        if let firstViewController = coordinators.first?.rootViewController {
            didUpdate(tabBarController: tabBarController, selectedViewController: firstViewController)
        }
    }

    open func didUpdate(tabBarController: UITabBarController, selectedViewController: UIViewController) {
        tabBarController.title = selectedViewController.title
        tabBarController.navigationItem.leftBarButtonItems = selectedViewController.navigationItem.leftBarButtonItems
        tabBarController.navigationItem.rightBarButtonItems = selectedViewController.navigationItem.rightBarButtonItems
    }
}

extension TabBarCoordinator: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        didUpdate(tabBarController: tabBarController, selectedViewController: viewController)
    }
}
