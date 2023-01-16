//
//  ViewController.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 13.01.2023.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet weak private var usersListTableView: UITableView!
    
    private var users : [UsersList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersListTableView.delegate = self
        usersListTableView.dataSource = self
    }
    
    @IBAction private func fetchButtonPressed(_ sender: Any) {
    makeRequest()
        usersListTableView.reloadData()
    }
    func makeRequest() {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/users"
        
        components.queryItems = [URLQueryItem(name: "since", value: "100000"),
                                 URLQueryItem(name: "per_page", value: "1000")]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("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", forHTTPHeaderField: "Authorization")
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
            } catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
}

extension ViewController: UITableViewDataSource {
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

extension ViewController: UITableViewDelegate {
    
}
