//
//  HomeViewModel.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import Foundation

class HomeViewModel {
    //MARK: Properties
    var networkRequestError    : NetworkRequestError?
    var networkRequestSuccess  : NetworkRequestSuccess?
    
    func fetchUserList(sinceId id: Int, withActivityIndicator activityIndicator: Bool = false){
        NetworkManager.shared.makeRequest(toUrl: "\(BASE_URL)?since=\(id)",
                                          withActivityIndicator: activityIndicator) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
                
            case .success(let data):
                do {
                    guard let responseObject = try JSONSerialization.jsonObject(
                        with: data, options: []
                    ) as? [[String: Any]] else {
                        strongSelf.networkRequestError?("Error trying to convert data to [[String: Any]]",
                                                        PARSING_FAILED)
                        return
                    }
                    let userList = responseObject.map({ UserListModel(withData: $0) })
                    MAIN_QUEUE.async { strongSelf.saveInCoreData(userList: userList) }
                    strongSelf.networkRequestSuccess?(Container(dataModel: userList))
                    
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
                                                       since: id,
                                                       username: nil)
                    }
                    strongSelf.networkRequestError?(error.localizedDescription, FALIURE)
                }
            }
        }
    }
    
    func saveInCoreData(userList: [UserListModel]){
        userList.forEach { user in
            let entries: [String: Any] = [
                "id": user.id,
                "username": user.userName,
                "avatarUrl": user.avatarUrl as Any
            ]
            
            CoreDataManager.shared.createData(withEntries: entries,
                                              forEntity: USER) { _ in
                Helper.debugLogs(anyData: "(User) Entries saved in the COREDATA",
                                 andTitle: "Success")
            }
        }
    }
    
    func setupFetchUserListNotificationObserver(){
        let selector = #selector(shouldFetchUserList(_:))
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: Constants.shared.fetchUserListNotification,
            object: nil)
    }
}

// MARK:- Objc-Interfaces
extension HomeViewModel {
    @objc func shouldFetchUserList(_ sender: Notification){
        if let failedRequest = FAILED_REQUEST, let since = failedRequest.since {
            fetchUserList(sinceId: since, withActivityIndicator: true)
        }
    }
}
