//
//  Helper.swift
//  GitHubUsers
//
//  Created by Jeff on 18/07/2021.
//

import UIKit

class Helper {
    
    /// - Parameters:
    ///   - data: The data to be printed
    ///   - title: Title of what is to be printed
    static func debugLogs(anyData data: Any, andTitle title: String = "Log") {
        #if DEBUG
        print("============= DEBUG LOGS START =================")
        print("\(title): \(data)")
        print("=============  DEBUG LOGS END  =================")
        print("\n \n")
        #endif
    }
    
    /// Setup the initial VC of our application
    /// - Parameter window: our application windows
    static func setInitialViewController(
        withScene scene: UIWindowScene? = nil
    ){
        let window: UIWindow
        let rootViewController   = HomeVC()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.isHidden = true
        
        if #available(iOS 13.0, *) {
            if let windowScene = scene {
                window = UIWindow(windowScene: windowScene)
                ///Forcing Light Mode
                window.overrideUserInterfaceStyle = .light
                window.rootViewController = navigationController /// Initial VC
                window.makeKeyAndVisible()
                SCENEDELEGATE?.window = window
            }
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = navigationController /// Initial VC
            window.makeKeyAndVisible()
            APPDELEGATE.window = window
        }
         
    }
    
    /// Post Notifications from notification center
    /// - Parameters:
    ///   - name: notification name
    ///   - userInfo: any data to be passed with notification
    static func postNotification(
        withName name: NSNotification.Name,
        andUserInfo userInfo: [AnyHashable : Any]? = nil) {
        
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }

    
    /// Show Activity Indicator
    static func showLoader(){
        MAIN_QUEUE.async {
            if let topVC = UIApplication.topViewController() {
                topVC.showSpinner(onView: topVC.view)
            }
        }
    }
    
    /// Remove Activity Indicator
    static func removeLoader(){
        MAIN_QUEUE.async {
            if let topVC = UIApplication.topViewController() {
                topVC.removeSpinner()
            }
        }
    }
            
    /// Show's loading indiicator in the tablevieew footer
    /// - Parameters:
    ///   - view: view on which inicator is to be shown
    ///   - color: color of the activity indicator
    /// - Returns: activity indicator
    static func showLoadingFooter(
        onView view     : UIView,
        withColor color : UIColor = UIColor.AppTheme.red) -> UIView {
        
        let footerView = UIView(
            frame: CGRect(
                x      : 0                ,
                y      : 0                ,
                width  : view.bounds.width,
                height : 80
            )
        )
        
        let spinner = UIActivityIndicatorView()
        
        spinner.style  = .medium
        spinner.center = footerView.center
        spinner.color  = color
        
        spinner.startAnimating()
        footerView.addSubview(spinner)
        
        return footerView
    }
}
