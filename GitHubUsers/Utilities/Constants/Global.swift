//
//  Global.swift
//  GitHubUsers
//
//  Created by Jeff on 18/07/2021.
//

import UIKit

// MARK: Constants
var SPINNER           : [UIView] = []
let APP_NAME          = "GitHub Users"
let DEFAULTS          = UserDefaults.standard
let MAIN_QUEUE        = DispatchQueue.main
let BG_QUEUE          = DispatchQueue.global(qos: .background)
let APPDELEGATE       = UIApplication.shared.delegate as! AppDelegate
let SCENEDELEGATE     = SceneDelegate.shared
let SCREEN_WIDTH      = UIScreen.main.bounds.width
let SCREEN_HEIGHT     = UIScreen.main.bounds.height
let RESULT_LIMIT      = 10
let BASE_URL          = "https://api.github.com/users"

// MARK: Core Data Entities
let USER     = "User"
let PROFILE  = "Profile"

// MARK: Application Enum
enum NetworkError: Error {
    case badCode(Int)
    case invalid(String)
    case timeout(String)
    case faliure(Error)
}
