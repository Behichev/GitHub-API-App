//
//  UsersViewController.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 13.01.2023.
//

import UIKit

final class UsersViewController: UIViewController {
    
    @IBOutlet weak private var usersListTableView: UITableView!
    
    private var users : [UsersList] = []
    private let searchController = UISearchController()
    
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        makeUsersRequest()
    }
    
    //MARK: - Functions
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Users"
        usersListTableView.delegate = self
        usersListTableView.dataSource = self
    }
    
    private func setupSearchBar() {
        self.navigationController?.navigationBar.topItem?.searchController = searchController
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func makeUsersRequest() {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/users"
        components.queryItems = [URLQueryItem(name: "since", value: "100"),
                                 URLQueryItem(name: "per_page", value: "100")]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("", forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
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
                let decodedObject = try decoder.decode([UsersList].self, from: data)
                self.users = decodedObject
                DispatchQueue.main.async {
                    self.usersListTableView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    private func makeSearchRequest(q: String) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/search/users"
        
        components.queryItems = [URLQueryItem(name: "q", value: q),
                                 URLQueryItem(name: "per_page", value: "100")]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("", forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
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
                let decodedObject = try decoder.decode(SearchResult.self, from: data)
                self.users = decodedObject.items
                DispatchQueue.main.async {
                    self.usersListTableView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
}

//MARK: - Table View Data Source

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = users[indexPath.row]
        cell.textLabel?.text = item.login
        return cell
    }
    
    
}

//MARK: - Table View Delegate

extension UsersViewController: UITableViewDelegate {
    
}

//MARK: - Search Bar Delegate

extension UsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        makeSearchRequest(q: text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        makeSearchRequest(q: text)
        usersListTableView.reloadData()
        searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        makeUsersRequest()
    }
}
