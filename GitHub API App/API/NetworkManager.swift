//
//  NetworkManager.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 19.01.2023.
//

import Foundation

struct NetworkManager {
    //MARK: - Properties
    var currentIDs = 0
    var isLoading = false
    fileprivate let apiKey = ""
    //MARK: - Functions
    func usersListRequest(since: Int , complition: @escaping(([UserModel]) -> Void)) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/users"
        components.queryItems = [URLQueryItem(name: "since", value: String(since)),
                                 URLQueryItem(name: "per_page", value: "100")]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Client error")
                return
            }
            
            guard let data = data else {
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedObject = try decoder.decode([GHUserModel].self, from: data)
                let users = decodedObject.map({ user in
                    return UserModel(username: user.login, userID: user.id, userAvatarUrl: user.avatarUrl)
                })
                complition(users)
            } catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    func userSearchRequest(_ q: String, complition: @escaping (([UserModel]) -> Void )) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/search/users"
        
        components.queryItems = [URLQueryItem(name: "q", value: q),
                                 URLQueryItem(name: "per_page", value: "100")]
        
        guard let url = components.url else { return }
        
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Client error")
                return
            }
            
            guard let data = data else {
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedObject = try decoder.decode(GHSearcResultModel.self, from: data)
                let users = decodedObject.items.map({ user in
                    return UserModel(username: user.login, userID: user.id, userAvatarUrl: user.avatarUrl)
                })
                complition(users)
            } catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
}
