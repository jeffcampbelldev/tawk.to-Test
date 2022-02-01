//
//  FailedRequest.swift
//  GitHubUsers
//
//  Created by Jeffon 28/01/2022.
//

import Foundation

/**
 This'll create an object of failed request due to internet connectivity
 */
class FailedRequest: Codable {
    ///Properties
    private (set) public var function: String
    private (set) public var since: Int? = nil
    private (set) public var username: String? = nil
    
    init(function: String, since: Int?, username: String?){
        self.function = function
        
        if let since = since {
            self.since = since
        }
        
        if let username = username {
            self.username = username
        }
    }
}
