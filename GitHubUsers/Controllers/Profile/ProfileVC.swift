//
//  ProfileVC.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import UIKit
import SkeletonView

class ProfileVC: UIViewController {

    /// IBOutlets
    @IBOutlet var extraLabels: [UILabel]!
    @IBOutlet var nameLabel: [UILabel]!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var blogLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    /// Properties
    public var username: String = ""
    public var avatarURL: URL?
    public var notes: String?
    
    private var profile: Observable<ProfileModel> = Observable(nil)
    private var viewModel: ProfileViewModel = ProfileViewModel()
    
    /// Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initVC()
    }
    
}

// MARK: Methods
extension ProfileVC {
    /**
     Intlilize the VC with the basic requirements
     */
    private func initVC(){
       initUI()
        
        setupObservables()
        setCallbacks()
        setupNotificationObservers()
        coreDataRequests(forUsername: username)
    }
    
    /**
     Intlilize the basic UI of the VC
     */
    private func initUI(){
        textView.text = "Please add note here.."
        textView.textColor = UIColor.AppTheme.lightGrey
        
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.AppTheme.black.cgColor
        
        textView.layer.cornerRadius = 12.0
    }
    
    /// Method to show skeletons animation
    func showSekletonView(){
        nameLabel.forEach { label in
            label.showAnimatedGradientSkeleton()
        }
        
        blogLabel.showAnimatedGradientSkeleton()
        emailLabel.showAnimatedGradientSkeleton()
        companyLabel.showAnimatedGradientSkeleton()
        followerLabel.showAnimatedGradientSkeleton()
        locationLabel.showAnimatedGradientSkeleton()
        followingLabel.showAnimatedGradientSkeleton()
        
        saveButton.showAnimatedGradientSkeleton()
        
        textView.showAnimatedGradientSkeleton()
        
        avatarImageView.showAnimatedGradientSkeleton()
        
        extraLabels.forEach { label in
            label.showAnimatedGradientSkeleton()
        }
    }
    
    /// Method to hide skeletons animation
    func hideSekletonView(){
        nameLabel.forEach { label in
            label.hideSkeleton()
        }
        
        blogLabel.hideSkeleton()
        emailLabel.hideSkeleton()
        companyLabel.hideSkeleton()
        followerLabel.hideSkeleton()
        locationLabel.hideSkeleton()
        followingLabel.hideSkeleton()
        
        saveButton.hideSkeleton()
        
        textView.hideSkeleton()
        
        avatarImageView.hideSkeleton()
        
        extraLabels.forEach { label in
            label.hideSkeleton()
        }
    }

    
    /// Setting up notification observers
    func setupNotificationObservers(){
        viewModel.setupFetchProfileNotificationObserver()
    }
    
    /// Observable values for view auto update
    private func setupObservables(){
        profile.bind { [weak self] _ in
            MAIN_QUEUE.async { self?.setData() }
        }
    }
    
    /// Set user's profile data on the View
    private func setData(){
        if let profile = profile.value {
            blogLabel.text      = profile.blog
            emailLabel.text     = profile.email
            companyLabel.text   = profile.company
            followerLabel.text  = "\(profile.followers)"
            locationLabel.text  = profile.location
            followingLabel.text = "\(profile.following)"
            
            nameLabel.forEach { label in
                label.text = profile.name
            }
            
            if let notes = self.notes {
                textView.text = notes
                textView.textColor = UIColor.AppTheme.black
            }
            
            if let avatarUrl = self.avatarURL {
                NetworkManager.shared.loadData(
                    url: avatarUrl,
                    withIndicatorOnImageView: avatarImageView
                ) { data, url, error in
                    MAIN_QUEUE.async { [weak self] in
                        if let data = data {
                            self?.avatarImageView.image = UIImage(data: data)
                        } else {
                            Helper.debugLogs(anyData: error as Any, andTitle: "ERROR")
                        }
                    }
                }
            } else {
                Helper.debugLogs(anyData: "Avatar URL is nil", andTitle: "ERROR")
            }

        }
    }
    
    /**
     Network requests Call at vc initilization for fetching user list
     */
    private func networkRequests(ofUser username: String, withActivityIndicator activityIndicator: Bool = false,
                                 andSkeleton skeleton: Bool = false) {
        if skeleton { showSekletonView() }
        viewModel.fetchProfile(ofUser: username, withActivityIndicator: activityIndicator)
    }
    
    /**
     coredata requests Call at vc initilization for fetching user list
     */
    private func coreDataRequests(forUsername username: String) {
        if let profile = CoreDataManager.shared.retrieveData(forEntity: PROFILE,
                                                             shouldAddCondition: true,
                                                             withKeyAndValue: ["username": username],
                                                             ofType: nil) as? ProfileModel {
            self.profile.value = profile
        } else {
            networkRequests(ofUser: username, andSkeleton: true)
        }
    }
    
    /**
     network requests Callbacks
     */
    private func setCallbacks() {
        networkRequestFaliureCallback()
        networkRequestSuccessCallback()
        networkRequestMessageCallback()
    }
}

//MARK: Actions
extension ProfileVC {
    @IBAction func didTapBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        if textView.textColor == UIColor.AppTheme.lightGrey {
            self.showAlertWithOption(title: nil,
                                     message: "Please add some text before saving",
                                     option1Title: OK)
        } else {
            if let profile = profile.value {
                viewModel.updateUserInCoreData(forUserWithId: Int32(profile.id),
                                               withEntriesForUser: ["notes": textView.text as Any])
            }
        }
    }
}

//MARK: TextView

///Delegate
extension ProfileVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.AppTheme.lightGrey {
            textView.text = nil
            textView.textColor = UIColor.AppTheme.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please add note here.."
            textView.textColor = UIColor.AppTheme.lightGrey
        }
    }
}

// MARK: API Callbacks
extension ProfileVC {
    func networkRequestFaliureCallback(){
        viewModel.networkRequestError = { [weak self] message, title in
            MAIN_QUEUE.async {
                self?.hideSekletonView()
                
                self?.showAlertWithOption(
                    title: title,
                    message: "\(message)",
                    option1Title: OK)
            }
        }
    }

    func networkRequestSuccessCallback(){
        viewModel.networkRequestSuccess = { [weak self] result in
            MAIN_QUEUE.async {
                self?.hideSekletonView()
            }
            if let profile = result.dataModel as? ProfileModel {
                self?.profile.value = profile
            }
        }
    }
    
    func networkRequestMessageCallback(){
        viewModel.networkRequestMessage = { [weak self] message, title in
            MAIN_QUEUE.async {
                self?.showAlertWithOption(
                    title: title,
                    message: "\(message)",
                    option1Title: OK)
            }
        }
    }
}
