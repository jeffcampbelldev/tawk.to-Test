//
//  UIApplication+Ext.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import UIKit

extension UIApplication {
    /// Get the topmost view controller
    /// - Parameter controller: root view controller
    /// - Returns: top view controller
    class func topViewController(controller: UIViewController? = UIWindow.key?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
