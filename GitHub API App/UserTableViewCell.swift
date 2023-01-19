//
//  UserTableViewCell.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 18.01.2023.
//

import UIKit

final class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var userNicknameLabel: UILabel!
    @IBOutlet weak private var userAvatarImage: UIImageView!
    @IBOutlet weak private var followersLabel: UILabel!
    @IBOutlet weak private var followingLabel: UILabel!
    
    private var cacheManager = CacheManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with item: GHUserModel) {
        userNicknameLabel.text = item.login
        followersLabel.text = item.followersUrl
        followingLabel.text = item.followingUrl
        if let imageURL = URL(string: item.avatarUrl) {
            cacheManager.downloadImage(url: imageURL) { image in
                self.userAvatarImage.image = image
            }
        }
    }
    
    override func prepareForReuse() {
        userAvatarImage.image = nil
        userNicknameLabel.text = nil
        followersLabel.text = nil
        followingLabel.text = nil
    }
    
    private func setupImageView() {
        userAvatarImage.layer.cornerRadius = (userAvatarImage.frame.size.width ) / 2
        userAvatarImage.clipsToBounds = true
        userAvatarImage.layer.borderWidth = 3.0
        userAvatarImage.layer.borderColor = UIColor.gray.cgColor
    }
    
}
