//
//  UIViewController+Ext.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import UIKit

extension UIViewController {
    /// Method to show the custom activity indicator
    /// - Parameters:
    ///   - view: on which the activity indicator is to be presented
    ///   - identifier: identifier for removing the spinner subview
    func showSpinner(
        onView view              : UIView              ,
        andIdentifier identifier : String   = "Default"
    ){
        let spinnerView = UIView(
            frame: UIScreen.main.bounds
        )
        
        spinnerView.backgroundColor         = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        spinnerView.accessibilityIdentifier = identifier
        
        let spinner   = UIActivityIndicatorView(style: .large)
        spinner.color = UIColor.AppTheme.red
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        spinner.startAnimating()
        
        spinnerView.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: spinnerView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: spinnerView.centerYAnchor).isActive = true
        
        view.addSubview(spinnerView)
        SPINNER.append(spinnerView)
    }
    
    /// Method to remove the custom activity indicator
    /// - Parameter identifier: identifier for removing the spinner subview
    func removeSpinner(withIdentifier identifier: String = "Default"){
        MAIN_QUEUE.async {
            for (index, spinner) in SPINNER.enumerated() {
                if spinner.accessibilityIdentifier == identifier {
                    spinner.removeFromSuperview()
                    if SPINNER.indices.contains(index){
                        SPINNER.remove(at: index)
                    }
                }
            }
        }
    }
    
    /// Method to show alert
    /// - Parameters:
    ///   - title: title of the alert
    ///   - message: message to show in alert
    ///   - option1Title: title of optioin 1
    ///   - option1Action: action of optioin 1
    ///   - option2Title: title of optioin 2
    ///   - option2Action: action of optioin 2
    func showAlertWithOption(
        title         : String?,
        message       : String?,
        option1Title  : String ,
        option1Action : (() -> Void)? = nil,
        option2Title  : String?       = nil,
        option2Action : (() -> Void)? = nil ) {
        
        let alert = UIAlertController(
            title          : title  ,
            message        : message,
            preferredStyle : .alert
        )
        
        alert.addAction(UIAlertAction(title: option1Title, style: .default, handler: { action in
            option1Action?()
        }))
        
        if let option2Title = option2Title {
            alert.addAction(UIAlertAction(title: option2Title, style: .default, handler: { action in
                option2Action?()
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}
