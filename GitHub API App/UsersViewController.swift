//
//  UsersViewController.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 13.01.2023.
//

import UIKit

final class UsersViewController: UIViewController {
    
    @IBOutlet weak private var usersListTableView: UITableView!
    
    private let searchController = UISearchController()
    private var arrayOfUsers: [GHUserModel] = []
    
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        delegates()
        fetchUsers()
    }
    
    //MARK: - Functions
    
    private func delegates() {
        usersListTableView.delegate = self
        usersListTableView.dataSource = self
        searchController.searchBar.delegate = self
        usersListTableView.register(UINib(nibName: AppConstants.Identifiers.userCellNib, bundle: nil), forCellReuseIdentifier: AppConstants.Identifiers.userCellReuseIdentifiere)
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Users"
        self.navigationController?.navigationBar.topItem?.searchController = searchController
        searchController.searchBar.placeholder = "Search"
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func fetchUsers() {
        NetworkManager.shared.makeUsersRequest { users in
            DispatchQueue.main.async {
                self.arrayOfUsers = users
                self.usersListTableView.reloadData()
            }
        }
    }
    
    private func searchUser(with query: String) {
        NetworkManager.shared.makeSearchRequest(q: query) { user in
            self.arrayOfUsers = user
            DispatchQueue.main.async {
                self.usersListTableView.reloadData()
            }
        }
    }
    
    
}

//MARK: - Table View Data Source

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayOfUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.Identifiers.userCellReuseIdentifiere) as? UserTableViewCell {
            let userItem = arrayOfUsers[indexPath.row]
            cell.configure(with: userItem)
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: - Table View Delegate

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
}

//MARK: - Search Bar Delegate

extension UsersViewController: UISearchBarDelegate {    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        searchUser(with: text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        searchUser(with: text)
        searchBar.text = ""
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchUsers()
    }
}
