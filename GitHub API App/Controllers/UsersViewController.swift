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
        resetCurrentPage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
            self.arrayOfUsers = user
            DispatchQueue.main.async {
                self.usersListTableView.reloadData()
            }
        }
    }
    
    private func resetCurrentPage() {
        networkManager.currentIDs = 0
        arrayOfUsers = [UserModel]()
        networkManager.makeUsersRequest(since: networkManager.currentIDs) { [weak self] users in
            self?.arrayOfUsers.append(contentsOf: users)
            
            DispatchQueue.main.async {
                self?.usersListTableView.reloadData()
            }
        }
    }
    
    private func nextPage() {
//        networkManager.currentIDs += 99
        
        networkManager.makeUsersRequest(since: networkManager.currentIDs) { [weak self] users in
            
            self?.arrayOfUsers.append(contentsOf: users)
            
            DispatchQueue.main.async {
                self?.usersListTableView.reloadData()
                self?.usersListTableView.tableFooterView = nil
            }
            print(self?.networkManager.currentIDs)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(arrayOfUsers[indexPath.row].userID)
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == arrayOfUsers.count - 1 {
//            networkManager.currentIDs += 29
//            print(arrayOfUsers.count)
//            nextPage()
//        }
//    }
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
        resetCurrentPage()
    }
}

extension UsersViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        networkManager.isLoadingData = false
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("didDecelerating")
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        usersListTableView.tableFooterView = createSpinnerFooter()

        if !networkManager.isLoadingData {
            if ((usersListTableView.contentOffset.y + usersListTableView.frame.size.height) >= usersListTableView.contentSize.height) {
                networkManager.isLoadingData = true
                networkManager.currentIDs += 29
                nextPage()
            }
        }
    }
}
