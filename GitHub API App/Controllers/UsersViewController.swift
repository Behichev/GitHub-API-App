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
    private var arrayOfUsers = [UserModel]()
    private var networkManager = NetworkManager()
    
    var timer: Timer?
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        delegates()
        
        networkManager.makeUsersRequest(since: networkManager.counter) { [weak self] users in
            self?.arrayOfUsers.append(contentsOf: users)
            
            DispatchQueue.main.async {
                self?.usersListTableView.reloadData()
            }
        }
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
    
    
    private func searchUser(with query: String) {
        networkManager.makeSearchRequest(q: query) { user in
            self.arrayOfUsers = user
            DispatchQueue.main.async {
                self.usersListTableView.reloadData()
            }
        }
    }
    
    private func refresh() {
        networkManager.counter = 0
        arrayOfUsers = [UserModel]()
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
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { [self] _ in
            searchUser(with: text)
        })
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        searchUser(with: text)
        searchBar.text = ""
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        refresh()
        
        networkManager.makeUsersRequest(since: networkManager.counter) { [weak self] users in
            self?.arrayOfUsers.append(contentsOf: users)
            
            DispatchQueue.main.async {
                self?.usersListTableView.reloadData()
            }
        }
    }
}

extension UsersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (usersListTableView.contentSize.height - 100 - scrollView.frame.size.height) {
            networkManager.counter += 100
            
            networkManager.makeUsersRequest(since: networkManager.counter) { [weak self] users in
                self?.arrayOfUsers.append(contentsOf: users)
                
                DispatchQueue.main.async {
                    self?.usersListTableView.reloadData()
                }
            }
        }
    }
}
