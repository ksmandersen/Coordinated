//
//  Coordinator.swift
//  Coordinated tvOS
//
//  Created by Kristian Andersen on 23/08/2018.
//  Copyright © 2018 Kristian Andersen. All rights reserved.
//

import Foundation
import UIKit

public protocol Coordinator: class {
    var children: [Coordinator] { get set }
    var rootViewController: UIViewController { get }

    func start()
}

extension Coordinator {
    public func coordinator(for viewController: UIViewController) -> Coordinator? {
        return children.first(where: { $0.rootViewController == viewController })
    }

    public func add(child coordinator: Coordinator) {
        guard !children.contains(where: { $0 === coordinator }) else { return }
        children.append(coordinator)
    }

    public func remove(child coordinator: Coordinator) {
        guard let index = children.index(where: { $0 === coordinator }) else { return }
        children.remove(at: index)
    }

    public func add(children coordinators: [Coordinator]) {
        coordinators.forEach(add)
    }

    public func remove(children coordinators: [Coordinator]) {
        coordinators.forEach(remove)
    }

    public func removeAll() {
        children.removeAll()
    }
}

extension Coordinator {
    public func present(viewController: UIViewController, animated: Bool = true) {
        let presenter = rootViewController.presentedViewController ?? rootViewController
        presenter.present(viewController, animated: animated)
    }

    public func present(coordinator: Coordinator, animated: Bool = true) {
        add(child: coordinator)
        present(viewController: coordinator.rootViewController, animated: animated)

        coordinator.start()
    }

    public func dismiss(coordinator: Coordinator, animated: Bool = true, completion: (() -> Void)?) {
        coordinator.rootViewController.dismiss(animated: animated) {
            self.remove(child: coordinator)
            completion?()
        }
    }

    public var presentedCoordinator: Coordinator? {
        return rootViewController.presentedViewController.flatMap(coordinator(for:))
    }
}

extension Coordinator {
    @discardableResult
    public func presentAlert(title: String, message: String,
                             defaultDismiss: Bool = true,
                             configure: ((UIAlertController) -> Void)? = nil,
                             onDismiss: (() -> Void)? = nil) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if defaultDismiss {
            let dismiss = UIAlertAction(title: "Ok",
                                        style: .default) { _ in
                controller.dismiss(animated: true)
                onDismiss?()
            }
            controller.addAction(dismiss)
        }

        configure?(controller)

        rootViewController.present(controller, animated: true, completion: nil)

        return controller
    }
}
