//
//  UIWindows+Ext.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import UIKit

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
