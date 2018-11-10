//
//  ViewController.swift
//  RealTimeChat
//
//  Created by Keith Cao on 10/06/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    
    let cellID = "userCell"
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(handleAddFriend))
        
        
        
        checkIfUserIsLogin()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.reloadData()
    }
    
    
    @objc func handleAddFriend() {
        print("add friend")
        let addfriendController =  AddFriendController(collectionViewLayout: UICollectionViewFlowLayout())
        addfriendController.messageConroller = self
        self.present(UINavigationController(rootViewController: addfriendController), animated: true, completion: nil)
        
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let message = self.messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerID() else { return }
        
        Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue { (error, ref) in
            
            if error != nil {
                print("fail to remove messages ", error as Any)
                return
            }
            
            self.messageDict.removeValue(forKey: chatPartnerId)
            self.handleReloadTable()
            
        }
        
        
    }
    
    var messages = [Message]()
    var messageDict = [String: Message]()
    var messageID = [String]()
    
    func loadMessagesOfCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userID = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                
                let messageID = snapshot.key
                
                let messageRef = Database.database().reference().child("messages").child(messageID)
                
                messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let dict = snapshot.value as? [String:Any] else {return}
                    let message = Message(dict: dict)
                    
                    
                    
                    if let chatPartnerID = message.chatPartnerID() {
                        
                        self.messageDict[chatPartnerID] = message
                        
                        
                        
                    }
                    
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    
                    
                    
                    
                }, withCancel: nil )
                
                
            }, withCancel: nil)
            
            
            
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messageDict.removeValue(forKey: snapshot.key)
            self.handleReloadTable()
            
            
        }, withCancel: nil)
        
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        
        self.messages = Array(self.messageDict.values)
        self.messages.sort(by: {$0.timestamp?.compare($1.timestamp!) == .orderedDescending})
        
        DispatchQueue.main.async {
            print("reload table")
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let msg = messages[indexPath.item]
        
        cell.message = msg
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.item]
        
        
        guard let chatpartnerID = message.chatPartnerID() else { return }
        
        let ref = Database.database().reference().child("users").child(chatpartnerID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String:Any] {
                
                var user = User(dictionary: dict)
                user.id = chatpartnerID
                self.showChatControllerWithUser(user: user)
                
            }
            
        }, withCancel: nil)
        
        
        
    }
    
    
    @objc func handleNewMessage() {
        print("new messagesxr")
        
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }
    
    func checkIfUserIsLogin() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        }else {
            fetchUserWithNavBarTitile()
        }
    }
    
    func fetchUserWithNavBarTitile() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                let user =  User(dictionary: dictionary)
                
                self.setUpNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    
    func setUpNavBarWithUser(user: User) {
        
        messages.removeAll()
        messageDict.removeAll()
        tableView.reloadData()
        
        loadMessagesOfCurrentUser()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        
        
        
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrl(urlString: profileImageUrl)
        }
        
        titleView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        titleView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 4).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        
        
        
        self.navigationItem.titleView = titleView
        
        
    }
    
    func showChatControllerWithUser(user: User) {
        print("11111")
        let chatlogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatlogController, animated: true)
        chatlogController.receiver = user
        
    }
    
    @objc func handleLogout() {
        print("logout")
        
        do {
            try Auth.auth().signOut()
        }catch let err {
            print("sign out error",err)
        }
        
        print("log out from messageController")
        
        
        let loginController = LoginController()
        loginController.tabbarController = TabBarController()
        present(loginController, animated: true, completion: nil)
    }
    
}
