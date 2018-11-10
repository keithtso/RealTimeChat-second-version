//
//  NewMessageController.swift
//  RealTimeChat
//
//  Created by Keith Cao on 11/06/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase


class NewMessageController: UITableViewController, UISearchBarDelegate {
    
    var messageController: MessageController?
    
    let cellID = "cellID"
    
    var users = [User]()
    
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Enter the name"
        bar.tintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.init(r: 240, g: 240, b: 240)
        bar.delegate = self
        return bar
    }()
    
    var filterUsers = [User]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filterUsers = self.users
            print(filterUsers)
        }else {
            filterUsers = users.filter { (user) -> Bool in
                return (user.name?.lowercased().contains(searchText.lowercased()))!
            }
        }
        
        self.tableView.reloadData()
    }
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        return button
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        fetchUser()
        
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: cellID)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        
        navigationItem.titleView = searchBar
        
        
    }
    
    func fetchUser() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        Database.database().reference().child("users").child(currentUserID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {return}
            guard let email = dict["email"] as? String else {return}
            let currentUserEmail = email.encodeKey()
            
            
            Database.database().reference().child("emailID").child(currentUserEmail).child("friend").observe(.childAdded, with: { (snapshot) in
                
                let userID = snapshot.key
                
                Database.database().reference().child("users").child(userID).observe(.value, with: { (snapshot) in
                    
                    if let dict = snapshot.value as? [String: Any] {
                        var user = User(dictionary: dict)
                        
                        user.id = snapshot.key
                        self.users.append(user)
                        
                        
                    }
                    
                    self.users.sort(by: {$0.name!.compare($1.name!) == .orderedAscending})
                    self.filterUsers = self.users
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }, withCancel: nil)
                
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! NewMessageCell
        let user1 = filterUsers[indexPath.row]
        
        
        cell.textLabel?.text = user1.name
        cell.detailTextLabel?.text = user1.email
        
        
        if let profileImageUrl = user1.profileImageUrl {
            
            cell.profileImage.loadImageUsingCacheWithUrl(urlString: profileImageUrl)
            
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return filterUsers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("dismiss done")
            
            self.searchBar.resignFirstResponder()
            
            let user = self.filterUsers[indexPath.item]
            self.messageController?.showChatControllerWithUser(user: user)
        }
        
    }
    
    
    
}
