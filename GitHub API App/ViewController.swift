//
//  UsersViewController.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 13.01.2023.
//

import UIKit

final class UsersViewController: UIViewController {
    
    @IBOutlet weak private var usersListTableView: UITableView!
    
    private var users : [GHUserModel] = []
    private let searchController = UISearchController()
    private var userInstance: GHAuthenticatedUserModel?
    
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        
        NetworkManager.shared.makeUsersRequest { request in
            self.users = request
            DispatchQueue.main.async {
                self.usersListTableView.reloadData()
            }
        }
        
    }
    
    //MARK: - Functions
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Users"
        usersListTableView.delegate = self
        usersListTableView.dataSource = self
        usersListTableView.register(UINib(nibName: AppConstants.Identifiers.userCellNib, bundle: nil), forCellReuseIdentifier: AppConstants.Identifiers.userCellReuseIdentifiere)
    }
    
    private func setupSearchBar() {
        self.navigationController?.navigationBar.topItem?.searchController = searchController
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
}

//MARK: - Table View Data Source

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.Identifiers.userCellReuseIdentifiere) as? UserTableViewCell {
            let userItem = users[indexPath.row]
            cell.configure(with: userItem)
            return cell
        }
        return UITableViewCell()
    }
    
    
}

//MARK: - Table View Delegate

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        return UITableView.automaticDimension
        return 132
    }
}

//MARK: - Search Bar Delegate

extension UsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        
        NetworkManager.shared.makeSearchRequest(q: text) { user in
            self.users = user
        }
        
        DispatchQueue.main.async {
            self.usersListTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        
        NetworkManager.shared.makeSearchRequest(q: text) { user in
            self.users = user
        }
        
        usersListTableView.reloadData()
        searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        NetworkManager.shared.makeUsersRequest { users in
            self.users = users
        }
        DispatchQueue.main.async {
            self.usersListTableView.reloadData()
        }
        
    }
}
