//
//  ProfileController.swift
//  RealTimeChat
//
//  Created by Keith Cao on 1/08/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase



class ProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate,ProfileChanging, RemoveRequestDelegate {
    
    func removeRequest(requestID: String?) {
        guard let key = requestID else { return }
        self.requestDict.removeValue(forKey: key)
        
        self.hanleReload()
    }
    
    func hanleReload() {
        
        
        requests = Array(self.requestDict.values)
        requests.sort(by: {$0.date!.compare($1.date!) == .orderedDescending})
        
        DispatchQueue.main.async {
            print("reload table")
            self.collectionView?.reloadData()
        }
    }
    
    
    var requestDict = [String: Requst]()
    
    var header: ProfileHeader?
    
    var image: UIImage?
    
    func changeProfileImage(header: ProfileHeader?){
        
        
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.header = header
        present(picker, animated: true, completion: nil)
        
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            self.image = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.image = originalImage
        }
        
        header?.profileImageView.image = self.image
        header?.imageChanged = true
        
        dismiss(animated: true, completion: nil)
        collectionView?.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        header?.imageChanged = false
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    let headerID = "headerID"
    let cellID = "CellID"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView?.backgroundColor = .white
        
        UIViewController.setUpCollectionViewSafearea(view: view, subview: self.collectionView!)
        
        collectionView?.alwaysBounceVertical = true
        
        navigationItem.setUpNavTitle(nameLabel: "Profile")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        collectionView?.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        
        collectionView?.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SecondHeader")
        
        collectionView?.register(UserProfileCell.self, forCellWithReuseIdentifier: cellID)
        
        fetchRequsts()
        
    }
    
    fileprivate func fetchRequsts() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("friend_requst").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else { return }
            
            var request = Requst(Dictionary: dict)
            request.currentUserID = uid
            request.requestID = snapshot.key
            guard let fromID = request.fromId else {
                return
            }
            
            Database.database().reference().child("users").child(fromID).observe(.value, with: { (snapshot) in
                
                guard let userDict = snapshot.value as? [String: Any] else {return}
                
                var user = User(dictionary: userDict)
                user.id = fromID
                self.users.append(user)
                
                self.requests.append(request)
                
                self.requestDict[request.requestID!] = request
                
                self.hanleReload()
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    @objc func handleLogout() {
        print("logout")
        
        do {
            try Auth.auth().signOut()
        }catch let err {
            print("sign out error",err)
        }
        
        let loginController = LoginController()
        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? TabBarController else { return }
        print("reach here")
        loginController.tabbarController = mainTabBarController
        present(loginController, animated: true, completion: nil)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 0 {
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! ProfileHeader
            header.delegate = self
            return header
        } else {
            
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            layout?.sectionHeadersPinToVisibleBounds = true
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SecondHeader", for: indexPath)
            let label = UILabel ()
            label.text = "Friend Requests"
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            
            header.backgroundColor = UIColor.init(r: 81, g: 133, b: 237)
            header.addSubview(label)
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 40).isActive = true
            label.widthAnchor.constraint(equalToConstant: 150).isActive = true
            
            return header
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize(width: collectionView.frame.width, height: 200)
        }else {
            return CGSize(width: collectionView.frame.width, height: 40)
        }
        
    }
    
    var requests = [Requst]()
    var users = [User]()
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }else {
            
            return requests.count
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserProfileCell
        
        let user = users[indexPath.item]
        let request = requests[indexPath.item]
        cell.user = user
        cell.request = request
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    
}
