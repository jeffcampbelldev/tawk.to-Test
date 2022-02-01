//
//  ProfileViewModel.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import Foundation

class ProfileViewModel {
    //MARK: Properties
    var networkRequestError    : NetworkRequestError?
    var networkRequestSuccess  : NetworkRequestSuccess?
    var networkRequestMessage  : NetworkRequestMessage?
    
    func fetchProfile(ofUser username: String, withActivityIndicator activityIndicator: Bool = false){
        NetworkManager.shared.makeRequest(toUrl: "\(BASE_URL)/\(username)",
                                          withActivityIndicator: activityIndicator) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let data):
                do {
                    guard let responseObject = try JSONSerialization.jsonObject(
                        with: data, options: []
                    ) as? [String: Any] else {
                        strongSelf.networkRequestError?("Error trying to convert data to [String: Any]",
                                                        PARSING_FAILED)
                        return
                    }
                    
                    let profile = ProfileModel(withData: responseObject)
                    MAIN_QUEUE.async { strongSelf.saveInCoreData(profile: profile) }
                    strongSelf.networkRequestSuccess?(Container(dataModel: profile))
                    
                    FAILED_REQUEST = nil
                } catch {
                    strongSelf.networkRequestError?("Error trying to convert data to JSON",
                                                    PARSING_FAILED)
                    return
                }
            case .failure(let result):
                switch result {
                case .badCode(let code):
                    strongSelf.networkRequestError?(code, BAD_CODE)
                case .invalid(let message):
                    strongSelf.networkRequestError?(message, INVALID)
                case .timeout(let message):
                    strongSelf.networkRequestError?(message, TIME_OUT)
                case .faliure(let error):
                    if !DATA_CONNECTION {
                        FAILED_REQUEST = FailedRequest(function: #function,
                                                       since: nil,
                                                       username: username)
                    }
                    strongSelf.networkRequestError?(error.localizedDescription, FALIURE)
                }
            }
        }
    }
    
    func saveInCoreData(profile: ProfileModel){
        
        let entries: [String: Any] = [
            "id": profile.id,
            "username": profile.username,
            "name": profile.name,
            "blog": profile.blog,
            "location": profile.location,
            "email": profile.email,
            "followers": profile.followers,
            "following": profile.following,
            "company": profile.company,
        ]
        
        CoreDataManager.shared.createData(withEntries: entries,
                                          forEntity: PROFILE) { _ in
            Helper.debugLogs(anyData: "(Profile) Entries saved in the COREDATA",
                             andTitle: "Success")
        }
    }
    
    func updateUserInCoreData(forUserWithId id: Int32, withEntriesForUser user: [String: Any]){
        CoreDataManager.shared.upateData(withId: id,
                                         forEntity: USER,
                                         withEntries: user) { [weak self] completion in
            guard let strongSelf = self else { return }
            if completion {
                strongSelf.networkRequestMessage?("Notes updated successfully", SUCCESS)
            } else {
                strongSelf.networkRequestMessage?("Notes update faliure", FALIURE)
            }
        }
    }
    
    func setupFetchProfileNotificationObserver(){
        let selector = #selector(shouldFetchProfile(_:))
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: Constants.shared.fetchProfileNotification,
            object: nil)
    }
}

// MARK:- Objc-Interfaces
extension ProfileViewModel {
    @objc func shouldFetchProfile(_ sender: Notification){
        if let failedRequest = FAILED_REQUEST, let username = failedRequest.username {
            fetchProfile(ofUser: username, withActivityIndicator: true)
        }
    }
}
