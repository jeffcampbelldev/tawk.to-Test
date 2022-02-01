//
//  UserList.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import Foundation

class UserListModel: Codable, RowViewModel {
    /// Properties
    internal (set) public var id: Int
    private (set) public var userName: String
    private (set) public var avatarUrl: URL? = nil
    
    public var notes : String? = nil
    
    /**
     Initillize the UserListModel from the API data
     */
    init(withData data: [String: Any]) {
        id       = data["id"] as! Int
        userName = data["login"] as! String
        
        if let avatarUrl = URL(string: data["avatar_url"] as! String) {
            self.avatarUrl = avatarUrl
        }
    }
    
    /**
     Initillize the UserListModel from the coredata
     */
    init(withId id: Int32, username: String, notes: String?, andAvatarUrl avatarUrl: URL) {
        self.id        = Int(id)
        self.userName  = username
        self.notes     = notes
        self.avatarUrl = avatarUrl
    }
}

class UserListInvertedModel: Codable, RowViewModel {
    /// Properties
    internal (set) public var id: Int
    private (set) public var userName: String
    private (set) public var avatarUrl: URL? = nil
    public var notes : String? = nil
    
    /**
     Initillize the UserListNotesModel from the coredata
     */
    init(withUser user: UserListModel) {
        self.id        = user.id
        self.userName  = user.userName
        self.notes     = user.notes
        self.avatarUrl = user.avatarUrl
    }
}

class UserListNotesModel: Codable, RowViewModel {
    /// Properties
    internal (set) public var id: Int
    private (set) public var userName: String
    private (set) public var avatarUrl: URL? = nil
    private (set) public var notes : String
    
    /**
     Initillize the UserListNotesModel from the coredata
     */
    init(withUser user: UserListModel) {
        self.id        = user.id
        self.userName  = user.userName
        self.notes     = user.notes!
        self.avatarUrl = user.avatarUrl
    }
}
