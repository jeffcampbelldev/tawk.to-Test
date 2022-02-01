//
//  SceneDelegate.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import UIKit
import Reachability

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    ///Properties
    var window: UIWindow?
    let reachability = try! Reachability()
    var reachabilityView: UIView = UIView()
    private(set) static var shared: SceneDelegate?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        Self.shared = self
        ///Setting up initial VC
        Helper.setInitialViewController(withScene: windowScene)
        
        ///Internet Reachability Setup
        NotificationCenter.default.addObserver(self,
                                               selector : #selector(self.reachabilityChanged(_:)),
                                               name     : .reachabilityChanged,
                                               object   : reachability)
        do {
            try reachability.startNotifier()
        } catch {
            Helper.debugLogs(anyData: error.localizedDescription,
                             andTitle: FALIURE)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

//MARK: Reachability
extension SceneDelegate {
    @objc func reachabilityChanged(_ note: NSNotification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi, .cellular:
            if let failedRequest = FAILED_REQUEST, let topVC = UIApplication.topViewController() {
                if failedRequest.function.contains("fetchUserList"), topVC.isKind(of: HomeVC.self) {
                    Helper.postNotification(withName: Constants.shared.fetchUserListNotification,
                                            andUserInfo: nil)
                } else if failedRequest.function.contains("fetchProfile"), topVC.isKind(of: ProfileVC.self) {
                    Helper.postNotification(withName: Constants.shared.fetchProfileNotification,
                                            andUserInfo: nil)
                }
            }
            DATA_CONNECTION = true
            addReachabilityView(WithText: "Online",
                                AndBGColor: UIColor.AppTheme.green)
        default:
            DATA_CONNECTION = false
            addReachabilityView(WithText: "Offline",
                                AndBGColor: UIColor.AppTheme.red)
        }
    }
    
    func addReachabilityView(WithText text: String, AndBGColor color: UIColor){
        if let topVC = UIApplication.topViewController() {
            let frame = CGRect(x: 0,
                               y: UIScreen.main.bounds.height - 40.0,
                               width: UIScreen.main.bounds.width,
                               height: 40.0)
            
            reachabilityView.frame = frame
            reachabilityView.backgroundColor = color
            
            let label  = UILabel()
            label.font = UIFont(name: "Helvetica Neue", size: 16.0)!
            label.text = text
            label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            label.textAlignment = .center
            
            let labelFrame = CGRect(x: ((frame.width/2) - 25.0),
                                    y: ((frame.height/2) - 10.0),
                                    width: 50.0,
                                    height: 20)
            
            label.frame = labelFrame
            reachabilityView.addSubview(label)
            
            topVC.view.addSubview(reachabilityView)
            
            removeReachabilityView()
        }
    }
    
    func removeReachabilityView() {
        MAIN_QUEUE.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            guard let strongSelf = self else { return }
            for view in strongSelf.reachabilityView.subviews {
                view.removeFromSuperview()
            }
            strongSelf.reachabilityView.removeFromSuperview()
        }
    }
}
