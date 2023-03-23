//
//  UserModel.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 16.03.2023.
//

import Foundation

struct UserModel: Hashable {
    
    let username: String
    let userID: Int
    let userAvatarUrl: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
        hasher.combine(username)
        hasher.combine(userAvatarUrl)
    }
}
