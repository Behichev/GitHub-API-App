//
//  NetworkManager.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 19.01.2023.
//

import Foundation

struct NetworkManager {
    
    static let shared = NetworkManager()
    
    private let apiKey = ""
    
    func makeUsersRequest(complition: @escaping(([GHUserModel]) -> Void)) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/users"
        components.queryItems = [URLQueryItem(name: "since", value: "0"),
                                 URLQueryItem(name: "per_page", value: "30")]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
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
                complition(decodedObject)
            } catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    func userInfoRequest(with userName: String, complition: @escaping (GHAuthenticatedUserModel) -> Void) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/users/\(userName)"
        
        
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
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
                let decodedObject = try decoder.decode(GHAuthenticatedUserModel.self, from: data)
                complition(decodedObject)
                print(decodedObject)
            } catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    func makeSearchRequest(q: String, complition: @escaping (([GHUserModel]) -> Void )) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/search/users"
        
        components.queryItems = [URLQueryItem(name: "q", value: q),
                                 URLQueryItem(name: "per_page", value: "30")]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
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
                complition(decodedObject.items)
            } catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
}
