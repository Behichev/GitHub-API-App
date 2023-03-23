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
    private var arrayOfUsers = [UserModel]()
    private var networkManager = NetworkManager()
    
    var timer: Timer?
    
    typealias DataSource = UITableViewDiffableDataSource<Section, UserModel>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, UserModel>
    
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()
    
    enum Section {
        case main
    }
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        snapshot.appendSections([Section.main])
        resetCurrentPage()
        configureTableViewDataSource()
        setupUI()
        delegates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    //MARK: - Functions
    private func delegates() {
        usersListTableView.delegate = self
        //        usersListTableView.dataSource = self
        searchController.searchBar.delegate = self
        usersListTableView.register(UINib(nibName: AppConstants.Identifiers.userCellNib, bundle: nil), forCellReuseIdentifier: AppConstants.Identifiers.userCellReuseIdentifiere)
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Users"
        self.navigationController?.navigationBar.topItem?.searchController = searchController
        searchController.searchBar.placeholder = "Search"
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        usersListTableView.separatorStyle = .none
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    private func searchUser(with query: String) {
        networkManager.makeSearchRequest(q: query) { user in
            self.applySnapshot(users: user)
        }
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
    
    private func resetCurrentPage() {
        networkManager.currentIDs = 0
        arrayOfUsers = [UserModel]()
        
        networkManager.makeUsersRequest(since: networkManager.currentIDs) { [weak self] users in
            self?.applySnapshot(users: users)
        }
    }
    
    private func loadMoreData() {
        networkManager.currentIDs += 99
        
        networkManager.makeUsersRequest(since: networkManager.currentIDs) { [weak self] users in
            self?.updateSnapshot(users)
            DispatchQueue.main.async {
                self?.networkManager.isLoading = false
            }
        }
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
            loadMoreData()
        }
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
            clearSnapshot()
            searchUser(with: text)
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else  {
            return
        }
        clearSnapshot()
        searchUser(with: text)
        searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearSnapshot()
        resetCurrentPage()
    }
}
