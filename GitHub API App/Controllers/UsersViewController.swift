//
//  UsersViewController.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 13.01.2023.
//

import UIKit

final class UsersViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak private var usersListTableView: UITableView!
    //MARK: - Properties
    private let searchController = UISearchController()
    private let acitivityIndicator = UIActivityIndicatorView()
    private var arrayOfUsers = [UserModel]()
    private var networkManager = NetworkManager()
    
    private var isFromSearchList = false
    private var timer: Timer?
    
    private typealias DataSource = UITableViewDiffableDataSource<Section, UserModel>
    private typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, UserModel>
    
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()
    
    private enum Section {
        case main
    }
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registesterNibs()
        configureTableViewDataSource()
        setupUI()
        delegates()
        performUsersListRequest()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    //MARK: - Functions
    private func delegates() {
        usersListTableView.delegate = self
        searchController.searchBar.delegate = self
    }
    
    private func registesterNibs() {
        usersListTableView.register(UINib(nibName: AppConstants.Identifiers.userCellNib,
                                          bundle: nil),
                                    forCellReuseIdentifier: AppConstants.Identifiers.userCellReuseIdentifiere)
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Users"
        self.navigationController?.navigationBar.topItem?.searchController = searchController
        searchController.searchBar.placeholder = "Search user"
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        usersListTableView.separatorColor = .link
        usersListTableView.separatorStyle = .none
        usersListTableView.backgroundView = acitivityIndicator
        acitivityIndicator.hidesWhenStopped = true
        acitivityIndicator.style = .large
        acitivityIndicator.color = .link
    }
    
    private func configureTableViewDataSource() {
        dataSource = DataSource(tableView: usersListTableView, cellProvider: { (tableView, indexPath, user) -> UserTableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.Identifiers.userCellReuseIdentifiere, for: indexPath) as! UserTableViewCell
            cell.configure(with: user)
            return cell
        })
    }
    
    private func applySnapshot(users: [UserModel]) {
        snapshot = DataSourceSnapshot()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(users, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateSnapshot(_ users: [UserModel]) {
        snapshot = dataSource.snapshot()
        snapshot.appendItems(users, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func clearSnapshot() {
        let emptySnapshot = DataSourceSnapshot()
        dataSource.apply(emptySnapshot)
    }
    
    private func performUserSearchRequest(with query: String, with page: Int) {
        networkManager.userSearchRequest(query, page: page) { user in
            DispatchQueue.main.async {
                self.applySnapshot(users: user)
            }
        }
    }
    
    private func performUsersListRequest() {
        networkManager.currentIDs = 0
        networkManager.usersListRequest(since: networkManager.currentIDs) { [weak self] users in
            DispatchQueue.main.async {
                self?.applySnapshot(users: users)
            }
        }
    }
    
    private func loadMoreUsers() {
        networkManager.currentIDs += 99
        networkManager.usersListRequest(since: networkManager.currentIDs) { [weak self] users in
            DispatchQueue.main.async {
                self?.updateSnapshot(users)
            }
            self?.networkManager.isLoading = false
        }
    }
    
    private func loadMoreSearchResults() {
        networkManager.currentPage += 1
        if let text = searchController.searchBar.text {
            networkManager.userSearchRequest(text, page: networkManager.currentPage) { [weak self] user in
                DispatchQueue.main.async {
                    self?.updateSnapshot(user)
                }
                self?.networkManager.isLoading = false
            }
        }
    }
    
    private func resetSearch() {
        clearSnapshot()
        isFromSearchList = false
        networkManager.currentPage = 1
    }
}
//MARK: - Table View Delegate
extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !networkManager.isLoading && (indexPath.row == dataSource.snapshot().numberOfItems - 1) {
            networkManager.isLoading = true
            if isFromSearchList {
                loadMoreSearchResults()
            } else {
                loadMoreUsers()
            }
        }
    }
}
//MARK: - Search Bar Delegate
extension UsersViewController: UISearchBarDelegate {    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        networkManager.currentPage = 1
        DispatchQueue.main.async {
            self.acitivityIndicator.startAnimating()
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { [self] _ in
            performUserSearchRequest(with: text, with: networkManager.currentPage)
            DispatchQueue.main.async {
                self.acitivityIndicator.stopAnimating()
            }
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        DispatchQueue.main.async {
            self.acitivityIndicator.startAnimating()
        }
        clearSnapshot()
        performUserSearchRequest(with: text, with: networkManager.currentPage)
        DispatchQueue.main.async {
            self.acitivityIndicator.stopAnimating()
        }
        searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetSearch()
        performUsersListRequest()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        resetSearch()
        isFromSearchList = true
        return true
    }
}
