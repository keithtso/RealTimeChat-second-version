//
//  AddFriendController.swift
//  RealTimeChat
//
//  Created by Keith Cao on 9/08/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase

class AddFriendController: UICollectionViewController, UICollectionViewDelegateFlowLayout,UISearchBarDelegate {
    
    var user: User?
    var messageConroller: MessageController?
    
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Enter the ID"
        bar.tintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.init(r: 240, g: 240, b: 240)
        bar.delegate = self
        return bar
    }()
    
    var isHidden = true
    var userFound = true
    var selfFound = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView?.backgroundColor = .white
        self.navigationItem.title = "Search"
        let safeArea = view.safeAreaLayoutGuide
        
        collectionView?.layoutAnchor(top:safeArea.topAnchor , paddingTop: 0, bottom: safeArea.bottomAnchor, paddingBottom: 0, left: safeArea.leftAnchor, paddingLeft: 0, right: safeArea.rightAnchor, paddingRight: 0, height: 0, width: 0)
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.titleView = searchBar
        
        collectionView?.register(SearchCell.self, forCellWithReuseIdentifier: "cellID")
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! SearchCell
        cell.isHighlighted = true
        if isHidden {
            cell.notFoundLabel.isHidden = true
            cell.isHidden = true
        }else if !isHidden, let text = searchBar.text{
            
            if userFound  {
                
                if !selfFound {
                    cell.notFoundLabel.isHidden = true
                    cell.isHidden = false
                    cell.idLabel.text = text
                    
                } else {
                    
                    cell.notFoundLabel.isHidden = false
                    
                    cell.notFoundLabel.text = "Can not add youself"
                }
                
                
            } else {
                cell.notFoundLabel.isHidden = false
                
                cell.notFoundLabel.text = "User not found"
            }
        
        }
        return cell
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let searchID = searchBar.text?.encodeKey() else {return}
        
        searchBar.resignFirstResponder()
        fetchSearchUer(id: searchID)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    fileprivate func fetchSearchUer(id: String) {
        
        let ref = Database.database().reference().child("emailID")
        
        ref.observeSingleEvent(of:.value, with: { (snapshot) in
            
            if !snapshot.hasChild(id) {
                self.userFound = false
                self.collectionView?.reloadData()
                return
            }
            
            ref.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String:Any] {
                    guard let uid = dict["uid"] as? String else {return}
                    
                    guard let currentUID = Auth.auth().currentUser?.uid else { return }
                    
                    if uid == currentUID {
                        self.selfFound = true
                        self.collectionView?.reloadData()
                        return
                    }
                    
                    let userRef = Database.database().reference().child("users").child(uid)
                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        
                        if let userDict = snapshot.value as? [String:Any] {
                            let userTemp = User(dictionary: userDict)
                            
                            let searchUserProfileController = SearchUserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
                            searchUserProfileController.user = userTemp
                            searchUserProfileController.user?.id = uid
                            searchUserProfileController.messageController = self.messageConroller
                            
                            self.navigationController?.pushViewController(searchUserProfileController, animated: true)
                        }
                        
                        
                    }, withCancel: nil)
                    
                }
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
        
        
        
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            isHidden = true
            
        }else {
            isHidden = false
            
        }
        selfFound = false
        userFound = true
        collectionView?.reloadData()
    }
    
    
    @objc func handleCancel() {
        
        dismiss(animated: true, completion: nil)
    }
    
}




//MARK:-   Cell set up for search page
class SearchCell: UICollectionViewCell {
    
    let scopeImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "search")
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
        
    }()
    
    let searchLabel: UILabel = {
        
        let label = UILabel()
        
        label.text = "Seach: "
        
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return  label
    }()
    
    lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    let notFoundLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = UIColor.darkGray
        label.isHidden = true
        return  label
    }()
    
    fileprivate func setUpView() {
        
        addSubview(scopeImage)
        addSubview(searchLabel)
        addSubview(idLabel)
        addSubview(notFoundLabel)
        
        
        
        scopeImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        scopeImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        scopeImage.heightAnchor.constraint(equalToConstant: 44).isActive = true
        scopeImage.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        searchLabel.centerYAnchor.constraint(equalTo: scopeImage.centerYAnchor).isActive = true
        searchLabel.leftAnchor.constraint(equalTo: scopeImage.rightAnchor, constant: 4).isActive = true
        searchLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        idLabel.centerYAnchor.constraint(equalTo: searchLabel.centerYAnchor).isActive = true
        idLabel.leftAnchor.constraint(equalTo: searchLabel.rightAnchor, constant: 4).isActive = true
        idLabel.rightAnchor.constraint(equalTo:rightAnchor, constant: -4).isActive = true
        idLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        notFoundLabel.layoutAnchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, height: 0, width: 0)
        
        let seperatorLine = UIView()
        addSubview(seperatorLine)
        seperatorLine.backgroundColor = .lightGray
        seperatorLine.layoutAnchor(top: bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, height: 0.5, width: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
        
        
    }
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                backgroundColor = .lightGray
            }else {
                backgroundColor = .white
            }
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

