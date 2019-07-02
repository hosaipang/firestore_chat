//
//  UsersTableViewController.swift
//  RTC
//
//  Created by king on 2/7/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import Foundation

protocol UsersTableViewControllerDelegate: NSObject {
    func didSingleTap(user: MemberUser)
}

class UsersTableViewController: UITableViewController {
    var isMultiSelection = false
    weak var delegate: UsersTableViewControllerDelegate?
    
    private let cellIdentifier = "UserCell"
    
    private var usersList = [MemberUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as? AppDelegate
        guard let chatManager = delegate?.chatManager else {
            return
        }
        
        if !isMultiSelection {
            usersList = chatManager.memberUsers.filter{ $0.userId != chatManager.uid }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        let user = usersList[indexPath.row]
        cell.textLabel?.text = user.userId
        cell.detailTextLabel?.text = user.online ? "Online" : "Offline"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isMultiSelection {
            let user = usersList[indexPath.row]
            delegate?.didSingleTap(user: user)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension UsersTableViewController: ChatManagerUserDelegate {
    func memberUserDidChange() {
        self.tableView.reloadData()
    }
}
