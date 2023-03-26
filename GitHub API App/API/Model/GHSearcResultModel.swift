//
//  GITSearcResultModel.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 18.01.2023.
//

import Foundation

struct GHSearcResultModel: Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [GHUserData]
}
