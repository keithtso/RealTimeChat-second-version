//
//  ProfileHeader.swift
//  RealTimeChat
//
//  Created by Keith Cao on 8/08/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase


protocol ProfileChanging {
    
    func changeProfileImage (header: ProfileHeader?)
    
}

class ProfileHeader: UICollectionViewCell, UINavigationControllerDelegate{
    
    
    var imageChanged = false
    var textChanged = false
    
    var text: String?
    
    var delegate: ProfileChanging?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "profile").withRenderingMode(.alwaysOriginal)
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var profileChangeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.isHidden = true
        button.addTarget(self, action: #selector(handleProfileChange), for: .touchUpInside)
        return button
    }()
    
    @objc func handleProfileChange() {
        
        print("Save profile")
        
        delegate?.changeProfileImage(header: self)
        
        
    }
    
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let userNameLabel: UITextField = {
        let label = UITextField()
        label.textAlignment = .center
        label.isEnabled = false
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.isHidden = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCancel() {
        print("cancel")
        
        userNameLabel.isEnabled = false
        userNameLabel.backgroundColor = .clear
        EditNameButton.setTitle("Edit", for: .normal)
        userNameLabel.resignFirstResponder()
        profileChangeButton.isHidden = true
        cancelButton.isHidden = true
        
    }
    
    
    lazy var EditNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleEdittingStatus), for: .touchUpInside)
        return button
    }()
    
    @objc func handleEdittingStatus() {
        
        if EditNameButton.currentTitle == "Edit" {
            handleEdit()
        }else if EditNameButton.currentTitle == "Save" {
            
            handleSave()
        }
        
        
    }
    
    
    func handleEdit() {
        print("edit")
        userNameLabel.isEnabled = true
        userNameLabel.backgroundColor = .white
        EditNameButton.setTitle("Save", for: .normal)
        profileChangeButton.isHidden = false
        cancelButton.isHidden = false
        
    }
    
    func handleSave() {
        print("save")
        userNameLabel.isEnabled = false
        userNameLabel.backgroundColor = .clear
        EditNameButton.setTitle("Edit", for: .normal)
        userNameLabel.resignFirstResponder()
        profileChangeButton.isHidden = true
        cancelButton.isHidden = true
        
        guard let uid = Auth.auth().currentUser?.uid else {return   }
        
        if !imageChanged {
            print("Same iamge")
        } else {
            
            let fileName = NSUUID().uuidString
            let ref = Storage.storage().reference().child("profileImage").child(fileName)
            
            guard let imageData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.3) else { return}
            
            ref.putData(imageData, metadata: nil) { (metaData, error) in
                
                if error != nil {
                    print("Fail to upload iamge ", error as Any)
                    return
                }
                
                ref.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        print("fail to get url ", error as Any)
                        return
                    }
                    
                    guard let imageUrl = url?.absoluteString else { return }
                    self.updateUserValues(uid: uid ,value: ["profileImageUrl": imageUrl])
                })
                
            }
            
            
        }
        
        if text == userNameLabel.text {
            print("Text Unchanged")
        } else {
            guard let name = userNameLabel.text else {return}
            
            updateUserValues(uid: uid , value: ["name": name])
        }
        
        
    }
    
    func updateUserValues(uid: String ,value: [String: Any]) {
        
        
        Database.database().reference().child("users").child(uid).updateChildValues(value)
        
    }
    
    
    let IDLabel: UITextView = {
        let label = UITextView()
        label.backgroundColor = UIColor.init(r: 236, g: 236, b: 236)
        label.isEditable = false
        label.isScrollEnabled = false
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let labelTwo: UILabel = {
        let label = UILabel()
        label.text = "ID:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    fileprivate func setUpProfileHeaderView() {
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(nameLabel)
        addSubview(EditNameButton)
        addSubview(IDLabel)
        addSubview(labelTwo)
        addSubview(profileChangeButton)
        addSubview(cancelButton)
        
        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        profileChangeButton.layoutAnchor(top: nil, paddingTop: 0, bottom: nil, paddingBottom: 0, left: profileImageView.rightAnchor, paddingLeft: 8, right: nil, paddingRight: 0, height: 40, width: 50)
        
        profileChangeButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        
        userNameLabel.layoutAnchor(top: profileImageView.bottomAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, height: 40, width: 180)
        userNameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        nameLabel.layoutAnchor(top: userNameLabel.topAnchor, paddingTop: 0, bottom: userNameLabel.bottomAnchor, paddingBottom: 0, left: nil, paddingLeft: 0, right: userNameLabel.leftAnchor, paddingRight: 0, height: 0, width: 70)
        
        
        EditNameButton.layoutAnchor(top: nil, paddingTop: 0, bottom: nil, paddingBottom: 0, left: userNameLabel.rightAnchor, paddingLeft: 4, right: nil, paddingRight: 0, height: 40, width: 40)
        
        EditNameButton.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor).isActive = true
        
        cancelButton.layoutAnchor(top: EditNameButton.topAnchor, paddingTop: 0, bottom: EditNameButton.bottomAnchor, paddingBottom: 0, left: EditNameButton.rightAnchor, paddingLeft: 4, right: rightAnchor, paddingRight: 4, height: 0, width: 0)
        
        
        IDLabel.layoutAnchor(top: userNameLabel.bottomAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: userNameLabel.leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 8, height: 30, width: 0)
        
        labelTwo.layoutAnchor(top: IDLabel.topAnchor, paddingTop: 0, bottom: IDLabel.bottomAnchor, paddingBottom: 0, left: nil, paddingLeft: 0, right: IDLabel.leftAnchor, paddingRight: 0, height: 0, width: 70)
        
        let seperatorLine = UIView()
        addSubview(seperatorLine)
        seperatorLine.backgroundColor = .black
        seperatorLine.layoutAnchor(top: bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, height: 0.5, width: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(r: 236, g: 236, b: 236)
        setUpProfileHeaderView()
        fetchUser()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func fetchUser(){
        if let uid = Auth.auth().currentUser?.uid {
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                if let dict = snapshot.value as? [String: Any] {
                    
                    if let name = dict["name"] as? String {
                        self.userNameLabel.text = name
                        self.text = name
                    }
                    
                    guard let profileImageUrl = dict["profileImageUrl"] as? String else {return}
                    self.profileImageView.loadImageUsingCacheWithUrl(urlString: profileImageUrl)
                    guard let idlabel = dict["email"] as? String else {return}
                    self.IDLabel.text = idlabel
                    
                    
                }
                
                
            }, withCancel: nil)
            
            
        }
        
    }
    
    
}
