//
//  HomeVC.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import UIKit
import SkeletonView

class HomeVC: UIViewController {
    /// IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// Properties
    private var SINCE: Int = 0/// Id of the last user that is fetched used for fetching data using the id as paginator
    private var userList: [UserListModel] = []
    private var cellData: Observable<[RowViewModel]> = Observable([])
    var viewModel: HomeViewModel = HomeViewModel()
    private var isFetchingData: Bool = false
    private var isSearching: Bool = false
    
    /// Lazy Properties
    lazy var userListNib: UINib = {
        return UINib(nibName: Constants.shared.UserListCell, bundle: nil)
    }()
    lazy var userListNotesNib: UINib = {
        return UINib(nibName: Constants.shared.UserListNotesCell, bundle: nil)
    }()
    lazy var userListInvertedNib: UINib = {
        return UINib(nibName: Constants.shared.UserListInvertedCell, bundle: nil)
    }()
    
    /// Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreDataRequests()
    }
}

// MARK: Methods
extension HomeVC {
    /**
     Intlilize the VC with the basic requirements
     */
    private func initVC(){
        initUI()
        
        setupObservables()
        setCallbacks()
        setupNotificationObservers()
    }
    
    /**
     Intlilize the basic UI of the VC
     */
    private func initUI(){
        searchBar.searchTextField.backgroundColor = UIColor.AppTheme.white
        registerNib()
    }
    
    /// Method to show skeletons animation
    func showSekletonView(){
        tableView.showAnimatedGradientSkeleton()
    }
    
    /// Method to hide skeletons animation
    func hideSekletonView(){
        tableView.hideSkeleton()
    }
    
    /**
     Register nib/s for the tableview
     */
    private func registerNib(){
        tableView.register(
            userListNib,
            forCellReuseIdentifier: Constants.shared.UserListCell)
        tableView.register(
            userListNotesNib,
            forCellReuseIdentifier: Constants.shared.UserListNotesCell)
        tableView.register(
            userListInvertedNib,
            forCellReuseIdentifier: Constants.shared.UserListInvertedCell)
    }
    
    /// Setting up notification observers
    func setupNotificationObservers(){
        viewModel.setupFetchUserListNotificationObserver()
    }
    
    /// Observable values for view auto update
    private func setupObservables(){
        cellData.bind { [weak self] _ in
            MAIN_QUEUE.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    /**
     Network requests at vc initilization for fetching user list
     */
    private func networkRequests(withActivityIndicator activityIndicator: Bool = false,
                                 andSkeleton skeleton: Bool = false) {
        if skeleton { showSekletonView() }
        viewModel.fetchUserList(sinceId: SINCE, withActivityIndicator: activityIndicator)
    }
    
    /**
     coredata requests Call at vc initilization for fetching user list
     */
    private func coreDataRequests() {
        if let userList = CoreDataManager.shared.retrieveData(forEntity: USER) as? [UserListModel] {
            self.userList = userList
            
            cellData.value = seperateDataTypeBased(userList: userList)
            
            if userList.indices.contains(userList.count-1) {
                SINCE = userList[userList.count-1].id
            }
        } else {
            networkRequests(andSkeleton: true)
        }
    }
    
    /**
     Seperates the user data in different modles based on their qualities
        - User's with notes
        - Every 4'th user's must have inverted image
        - remaining users
     */
    private func seperateDataTypeBased(userList: [UserListModel]) -> [RowViewModel] {
        let userListInverted = userList
            .enumerated()
            .filter({ ($0.offset+1)%4 == 0 })
            .map({ UserListInvertedModel(withUser: $0.element) })
        let remainingUsers = userList
            .enumerated()
            .filter({ ($0.offset+1)%4 != 0 && $0.element.notes == nil })
            .map({ $0.element })
        let userListNotes: [UserListNotesModel] = userList
            .enumerated()
            .filter({ ($0.offset+1)%4 != 0 && $0.element.notes != nil })
            .map({ UserListNotesModel(withUser: $0.element) })
        
        var combinedResult: [RowViewModel] = []
        combinedResult.append(contentsOf: userListNotes)
        combinedResult.append(contentsOf: userListInverted)
        combinedResult.append(contentsOf: remainingUsers)
                
        return combinedResult.sorted { $0.id < $1.id }
    }
    
    /**
     network requests Callbacks
     */
    private func setCallbacks() {
        networkRequestFaliureCallback()
        networkRequestSuccessCalllback()
    }
}

//MARK: TableView

///DataSource
extension HomeVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = cellData.value?.count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row  = indexPath.row
        let viewModel = cellData.value![row]
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier(for: viewModel))
        
        if let cell = cell as? CellConfigurable {
            cell.configure(withUser: viewModel)
        }
        
        return cell!
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView,
                                cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return Constants.shared.UserListCell
    }
    
    /// Map the view model with the cell identifier (which will be moved to the Controller)
    private func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is UserListModel:
            return Constants.shared.UserListCell
        case is UserListNotesModel:
            return Constants.shared.UserListNotesCell
        case is UserListInvertedModel:
            return Constants.shared.UserListInvertedCell
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
}

///Delegate
extension HomeVC: SkeletonTableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row       = indexPath.row
        let profileVC = ProfileVC(nibName: Constants.shared.profileVC, bundle: nil)
        
        if let user = cellData.value?[row] as? UserListModel {
            profileVC.notes     = user.notes
            profileVC.username  = user.userName
            profileVC.avatarURL = user.avatarUrl
        } else if let user = cellData.value?[row] as? UserListNotesModel {
            profileVC.notes     = user.notes
            profileVC.username  = user.userName
            profileVC.avatarURL = user.avatarUrl
        } else if let user = cellData.value?[row] as? UserListInvertedModel {
            profileVC.notes     = user.notes
            profileVC.username  = user.userName
            profileVC.avatarURL = user.avatarUrl
        }
         
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

// MARK: Scroll View

///Delegate
extension HomeVC: UIScrollViewDelegate{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tableView {
            if !isFetchingData && !isSearching {
                if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                    isFetchingData = true
                    tableView.tableFooterView = Helper.showLoadingFooter(onView: tableView)
                    networkRequests()
                }
            }
        }
    }
}

// MARK: SearchBar

///Delegate
extension HomeVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = false
        cellData.value = seperateDataTypeBased(userList: userList)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = true
        if let searchText = searchBar.text, searchText != "" {
            let result = userList.filter({
                $0.userName.lowercased().contains(searchText.lowercased()) ||
                $0.notes?.lowercased().contains(searchText.lowercased()) ?? false
            })
            cellData.value = seperateDataTypeBased(userList: result)
        } else {
            cellData.value = seperateDataTypeBased(userList: userList)
        }
    }
}


// MARK: API Callbacks
extension HomeVC {
    func networkRequestFaliureCallback(){
        viewModel.networkRequestError = { [weak self] message, title in
            MAIN_QUEUE.async {
                self?.tableView.tableFooterView = nil
                self?.hideSekletonView()
                
                self?.showAlertWithOption(
                    title: title,
                    message: "\(message)",
                    option1Title: OK)
            }
            self?.isFetchingData = false
        }
    }

    func networkRequestSuccessCalllback(){
        viewModel.networkRequestSuccess = { [weak self] result in
            MAIN_QUEUE.async {
                self?.tableView.tableFooterView = nil
                self?.hideSekletonView()
            }
            if let userList = result.dataModel as? [UserListModel] {
                self?.userList.append(contentsOf: userList)
                self?.cellData.value = self?.seperateDataTypeBased(userList: self!.userList)
                if userList.indices.contains(userList.count-1) {
                    self?.SINCE = userList[userList.count-1].id
                }
                self?.isFetchingData = false
            }
        }
    }
}
