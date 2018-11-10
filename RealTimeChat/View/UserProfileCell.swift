//
//  UserProfileCell.swift
//  RealTimeChat
//
//  Created by Keith Cao on 12/08/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase

protocol RemoveRequestDelegate {
    func removeRequest(requestID: String?)
}

class UserProfileCell: UICollectionViewCell {
    
    var delegate: RemoveRequestDelegate?
    
    var user: User? {
        
        didSet {
            
            guard let name = user?.name, let emailID = user?.email else { return }
            userNameLabel.text = name
            idLabel.text = emailID
            
            
        }
    }
    
    var request: Requst?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "profile").withRenderingMode(.alwaysOriginal)
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 26
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
       return label
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.init(r: 128, g: 191, b: 152)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return button
    }()
    
    @objc func handleAccept() {
        
        print("accept")
        handleRequest(accept: true, user: user)
        
        
    }
    
    
    lazy var declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Decline", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.init(r: 237, g: 109, b: 98)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleDecline), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDecline() {
        handleRequest(accept: false, user: user)
        
    }
    
   
    fileprivate func handleRequest(accept: Bool, user: User?) {
        
        guard let fromID = user?.id else {return}
        
        var currentUserEmail: String?
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        Database.database().reference().child("users").child(currentUserID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {return}
            guard let email = dict["email"] as? String else {return}
            currentUserEmail = email.encodeKey()
            
            guard let friendEmail = user?.email?.encodeKey() else {return}
            
            if accept {
                let ref = Database.database().reference().child("emailID")
                
                ref.child(currentUserEmail!).child("friend").child(fromID).updateChildValues(["relation":1])
                
                ref.child(friendEmail).child("friend").child(currentUserID).updateChildValues(["relation":1])
                Database.updateRequestNumber(difference: -1, id: currentUserID)
                self.deleteFriendRequest(requestID: self.request?.requestID)
                
            } else {
                
                Database.updateRequestNumber(difference: -1, id: currentUserID)
                self.deleteFriendRequest(requestID: self.request?.requestID)
                
                
            }
            
            
        }, withCancel: nil)
        
        
        
    }
    
    fileprivate func deleteFriendRequest(requestID: String?) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("friend_requst").child(uid).child(requestID!).removeValue { (error, ref) in
            if error != nil {
                print("fail to delete request ", error as Any)
                return
            }
            
            
            self.delegate?.removeRequest(requestID: requestID)
            
        }
        
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(idLabel)
        addSubview(acceptButton)
        addSubview(declineButton)
        
        
        profileImageView.layoutAnchor(top: nil, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 4, right: nil, paddingRight:0, height: 52, width: 52)
        
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
        
        declineButton.layoutAnchor(top: topAnchor, paddingTop: 10, bottom: bottomAnchor, paddingBottom: 10, left: nil, paddingLeft: 0, right: rightAnchor, paddingRight: 10, height: 0, width: 50)
        
        acceptButton.layoutAnchor(top: topAnchor, paddingTop: 10, bottom: bottomAnchor, paddingBottom: 10, left: nil, paddingLeft: 0, right: declineButton.leftAnchor, paddingRight: 4, height: 0, width: 50)
        
        userNameLabel.layoutAnchor(top: topAnchor, paddingTop: 4, bottom: nil, paddingBottom: 0, left: profileImageView.rightAnchor, paddingLeft: 4, right: acceptButton.leftAnchor, paddingRight: 4, height: 26, width: 0)
        
        idLabel.layoutAnchor(top: userNameLabel.bottomAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 4, left: userNameLabel.leftAnchor, paddingLeft: 0, right: acceptButton.leftAnchor, paddingRight: 4, height: 26, width: 0)

        
// Line to seperate sections
        let seperatorLine = UIView()
        addSubview(seperatorLine)
        seperatorLine.backgroundColor = .black
        seperatorLine.layoutAnchor(top: bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, height: 0.5, width: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
