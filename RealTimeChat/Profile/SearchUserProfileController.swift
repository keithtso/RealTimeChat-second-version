//
//  SearchUserProfileController.swift
//  RealTimeChat
//
//  Created by Keith Cao on 10/08/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase


class SearchUserProfileController: UICollectionViewController {
    
    var messageController: MessageController?
    
    
    var user: User? {
        didSet{
            guard let name = user?.name, let email = user?.email else {return}
            
            userNameLabel.text = name
            print(email)
            IDLabel.text = email
            
            guard let profileUrl = user?.profileImageUrl else { return }
            profileImageView.loadImageUsingCacheWithUrl(urlString: profileUrl)
        }
    }
    
    var isAdded = false
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "profile").withRenderingMode(.alwaysOriginal)
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 150/2
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 17, g: 154, b: 237)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleRequestButton), for: .touchUpInside)
        
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowRadius = 3.0
        button.layer.shadowOpacity = 1.0
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.masksToBounds = false
        
        return button
    }()
    
    
    @objc func handleRequestButton() {
        
        if addButton.titleLabel?.text == "Send Friend Request" {
            handleAdd()
            
        }else if addButton.titleLabel?.text == "Send Messages"  {
            
            handleSendMsg()
            
        }
        
        
    }
    
    fileprivate func handleSendMsg() {
        
        
        let chatlogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationController?.pushViewController(chatlogController, animated: true)
        chatlogController.receiver = self.user
        
        
    }
    
    fileprivate func handleAdd() {
        print("adddd")
        
        let ref = Database.database().reference().child("friend_requst")
        
        guard let fromID = Auth.auth().currentUser?.uid else { return }
        
        guard let toID = user?.id else { return }
        
        let date = NSDate().timeIntervalSince1970
        
        let values = ["from": fromID, "date": date] as [String:Any]
        
        
        ref.child(toID).childByAutoId().updateChildValues(values)
        
        Database.updateRequestNumber(difference: 1, id: toID)
        
    }
    
    let IDLabel: UITextView = {
        let label = UITextView()
        label.isEditable = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let labelTwo: UILabel = {
        let label = UILabel()
        label.text = "ID:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView?.backgroundColor = .white
        navigationItem.title = "User Info"
        UIViewController.setUpCollectionViewSafearea(view: view, subview: collectionView!)
        collectionView?.alwaysBounceVertical = true
        
        checkifUserIsAdded()
        
        setUpProfileLayout()
        
        
        
    }
    
    fileprivate func checkifUserIsAdded() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference()
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else { return }
            let email = dict["email"] as? String
            let emailID = email?.encodeKey()
            guard let userID = self.user?.id else {return}
            ref.child("emailID").child(emailID!).child("friend").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.hasChild(userID) {
                    self.self.addButton.setTitle("Send Messages", for: .normal)
                    
                    
                    
                }else {
                    self.addButton.setTitle("Send Friend Request", for: .normal)
                    self.isAdded = false
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        
        
    }
    
    
    fileprivate func setUpProfileLayout() {
        
        collectionView?.addSubview(profileImageView)
        collectionView?.addSubview(userNameLabel)
        collectionView?.addSubview(nameLabel)
        collectionView?.addSubview(IDLabel)
        collectionView?.addSubview(labelTwo)
        collectionView?.addSubview(addButton)
        
        //SET UP PROFILE IMAGEVIEW
        profileImageView.centerXAnchor.constraint(equalTo: (collectionView?.centerXAnchor)!).isActive = true
        profileImageView.topAnchor.constraint(equalTo: (collectionView?.topAnchor)!, constant: 12).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        userNameLabel.layoutAnchor(top: profileImageView.bottomAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, height: 40, width: 180)
        userNameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        nameLabel.layoutAnchor(top: userNameLabel.topAnchor, paddingTop: 0, bottom: userNameLabel.bottomAnchor, paddingBottom: 0, left: nil, paddingLeft: 0, right: userNameLabel.leftAnchor, paddingRight: 0, height: 0, width: 70)
        
        
        
        labelTwo.layoutAnchor(top: nameLabel.bottomAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: nameLabel.leftAnchor, paddingLeft: 0, right: nil, paddingRight: 0, height: 30, width: 70)
        
        IDLabel.layoutAnchor(top: labelTwo.topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: labelTwo.rightAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 8, height: 30, width: 0)
        
        
        
        addButton.layoutAnchor(top: IDLabel.bottomAnchor, paddingTop: 20, bottom: nil, paddingBottom: 0, left:nil, paddingLeft: 8, right: nil, paddingRight: 0, height: 40, width: 200)
        
        addButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        print("is added ", isAdded)
        if !isAdded {
            
        }else {
            
        }
    }
    
    
    @objc func handleCancel() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
