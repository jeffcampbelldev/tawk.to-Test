//
//  UserListNotesCell.swift
//  GitHubUsers
//
//  Created by Jeffon 29/01/2022.
//

import UIKit

class UserListNotesCell: UITableViewCell {
    ///IBOutlet
    @IBOutlet weak var nameLabel       : UILabel!
    @IBOutlet weak var containerView   : UIView!
    @IBOutlet weak var avatarImageView : UIImageView!
 
    //MARK: Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image  = nil
    }
    
}

//MARK: CellConfigurable
extension UserListNotesCell: CellConfigurable {
    func configure(withUser user: RowViewModel){
        if let user = user as? UserListNotesModel {
            initUI()
            
            nameLabel.text = user.userName
            
            if let avatarUrl = user.avatarUrl {
                NetworkManager.shared.loadData(
                    url: avatarUrl,
                    withIndicatorOnImageView: avatarImageView
                ) { data, url, error in
                    MAIN_QUEUE.async { [weak self] in
                        if let data = data {
                            let image = UIImage(data: data)
                            self?.avatarImageView.image = image
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
    
    func initUI(){
        selectionStyle = .none
        avatarImageView.image = nil
        
        MAIN_QUEUE.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.containerView.layer.borderColor  = UIColor.AppTheme.black.cgColor
            strongSelf.containerView.layer.borderWidth  = 2.0
            strongSelf.containerView.layer.cornerRadius = 12.0
            
            strongSelf.avatarImageView.layer.borderColor  = UIColor.AppTheme.black.cgColor
            strongSelf.avatarImageView.layer.borderWidth  = 2.0
            strongSelf.avatarImageView.layer.cornerRadius = strongSelf.avatarImageView.frame.height/2.0
        }
    }

}
