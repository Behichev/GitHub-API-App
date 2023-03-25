//
//  UserTableViewCell.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 18.01.2023.
//

import UIKit

public final class UserTableViewCell: UITableViewCell {
    //MARK: - Outlets
    @IBOutlet weak private var userNicknameLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var userAvatarImage: UIImageView!
    //MARK: - Properties
    private var cacheManager = CacheManager()
    private var item: UserModel?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }
    //MARK: - Functions
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with item: UserModel) {
        self.item = item
        userNicknameLabel.text = item.username
        if let imageURL = URL(string: item.userAvatarUrl) {
            cacheManager.downloadImage(url: imageURL) { [weak self] image in
                if item == self?.item {
                    DispatchQueue.main.async {
                        self?.userAvatarImage.image = image
                        self?.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
        
        public override func prepareForReuse() {
            userAvatarImage.image = nil
            userNicknameLabel.text = nil
            activityIndicator.startAnimating()
        }
        
        private func setupImageView() {
            userAvatarImage.layer.cornerRadius = (userAvatarImage.frame.size.width ) / 2
            userAvatarImage.clipsToBounds = true
            userAvatarImage.layer.borderWidth = 3.0
            userAvatarImage.layer.borderColor = UIColor.link.cgColor
        }
        
    }
