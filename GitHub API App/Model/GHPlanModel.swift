//
//  GHPlanModel.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 19.01.2023.
//

import Foundation

struct GHPlanModel: Decodable {
     let name: String
     let space: Int
     let privateRepos: Int
     let collaborators: Int
}
