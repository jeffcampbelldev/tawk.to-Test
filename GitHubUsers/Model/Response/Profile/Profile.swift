//
//  Profile.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import Foundation

class ProfileModel: Codable {
    /// Properties
    private (set) public var id        : Int
    private (set) public var username  : String
    private (set) public var name      : String
    private (set) public var company   : String
    private (set) public var blog      : String
    private (set) public var location  : String
    private (set) public var email     : String
    private (set) public var followers : Int
    private (set) public var following : Int
    
    /**
     Initillize the UserListModel from the API data
     */
    init(withData data: [String: Any]) {
        id        = data["id"]        as! Int
        username  = data["login"]     as! String
        name      = data["name"]      as! String
        company   = data["company"]   as? String ?? "None"
        blog      = data["blog"]      as? String ?? "None"
        location  = data["location"]  as? String ?? "None"
        email     = data["email"]     as? String ?? "None"
        followers = data["followers"] as? Int ?? 0
        following = data["following"] as? Int ?? 0
    }
    
    /**
     Initillize the UserListModel from the coredata
     */
    init(withId id: Int32, username: String, name: String, company: String, blog: String, location: String, email: String, followers: Int32, following: Int32) {
        self.id        = Int(id)
        self.username  = username
        self.name      = name
        self.company   = company
        self.blog      = blog
        self.location  = location
        self.email     = email
        self.followers = Int(followers)
        self.following = Int(following)
    }
}
