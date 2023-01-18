//
//  SearchResult.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 18.01.2023.
//

import Foundation

struct SearchResult: Decodable {
    let total_count: Int
    let incomplete_results: Bool
    let items: [UsersList]
}
