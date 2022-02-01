//
//  Constants.swift
//  GitHubUsers
//
//  Created by Jeff on 18/07/2021.
//

import Foundation

//MARK: Application Constants
struct Constants {
    static let shared: Constants = Constants()
    
    ///TableView Cells
    let UserListCell = "UserListCell"
    let UserListNotesCell = "UserListNotesCell"
    let UserListInvertedCell = "UserListInvertedCell"
    
    ///ViewControllers
    let profileVC = "ProfileVC"
    
    ///UserDefaults
    let dataConnection = "dataConnection"
    let failedRequest = "failedRequest"
    
    ///Notifications
    let fetchUserListNotification = NSNotification.Name("fetchUserListNotification")
    let fetchProfileNotification = NSNotification.Name("fetchProfileNotification")
}

var SESSION: URLSession = {
    let configuration: URLSessionConfiguration = .default
    configuration.requestCachePolicy           = .returnCacheDataElseLoad
    configuration.timeoutIntervalForRequest    = 10.0
    configuration.timeoutIntervalForResource   = 10.0
    
    return URLSession(configuration: .default)
}()

var DATA_CONNECTION: Bool {
    get {
        return DEFAULTS.value(forKey: Constants.shared.dataConnection) as! Bool
    } set {
        DEFAULTS.set(newValue, forKey: Constants.shared.dataConnection)
    }
}

/**
 Stores last failed request due to no data connection
 */
var FAILED_REQUEST: FailedRequest? {
    get {
        if let data = DEFAULTS.object(forKey: Constants.shared.failedRequest) as? Data {
            let decoder = JSONDecoder()
            if let failedRequest = try? decoder.decode(FailedRequest.self, from: data) {
               return failedRequest
            }
        }
        return nil
    } set {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(newValue) {
            DEFAULTS.set(encoded, forKey: Constants.shared.failedRequest)
        }
    }
}

//MARK: Application String Constants
var OK: String {
    return "Ok"
}
var YES: String {
    return "Yes"
}
var NO: String {
    return "No"
}
var TIME_OUT: String {
    return "TIME OUT"
}
var INVALID: String {
    return "INVALID"
}
var BAD_CODE: String {
    return "BAD CODE"
}
var FALIURE: String {
    return "FALIURE"
}
var PARSING_FAILED: String {
    return "PARSING FAILED"
}
var SUCCESS: String {
    return "SUCCESS"
}
