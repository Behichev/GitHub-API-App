//
//  UserTableViewCell.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 18.01.2023.
//

import UIKit

public final class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var userNicknameLabel: UILabel!
    @IBOutlet weak private var userAvatarImage: UIImageView!
    
    private var cacheManager = CacheManager()
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with item: UserModel) {
        userNicknameLabel.text = item.username
        if let imageURL = URL(string: item.userAvatarUrl) {
                cacheManager.downloadImage(url: imageURL) { image in
                    self.userAvatarImage.image = image
            }
        }
    }
    
    public override func prepareForReuse() {
        userAvatarImage.image = nil
        userNicknameLabel.text = nil
    }
    
    private func setupImageView() {
        userAvatarImage.layer.cornerRadius = (userAvatarImage.frame.size.width ) / 2
        userAvatarImage.clipsToBounds = true
        userAvatarImage.layer.borderWidth = 3.0
        userAvatarImage.layer.borderColor = UIColor.gray.cgColor
    }
    
}
