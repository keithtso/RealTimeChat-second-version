//
//  UserCell.swift
//  RealTimeChat
//
//  Created by Keith Cao on 18/07/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase


class  UserCell: UITableViewCell {
    
    var message: Message? {
        didSet{
            
            setUpNameAndProfileImage()
            
            if let msgText = message?.text {
                detailTextLabel?.text = msgText
            } else {
                detailTextLabel?.text = "[Image]"
            }
            
            
            timeLabel.text = message?.timestamp?.timeAgoDisplay()
            
        }
    }
    
    fileprivate func setUpNameAndProfileImage() {
        
        
        
        if let id = message?.chatPartnerID() {
            
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String:Any] {
                    self.textLabel?.text = dict["name"] as? String
                    
                    guard let url = dict["profileImageUrl"] as? String else { return }
                    
                    self.profileImage.loadImageUsingCacheWithUrl(urlString: url)
                }
                
            }) { (err) in
                print("fail to observe user with toID ", err)
            }
            
        }    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    
    
    let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "profile")
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "hh/mm/ss"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        
        
        addSubview(profileImage)
        
        profileImage.layoutAnchor(top: nil  , paddingTop: 0, bottom: nil, paddingBottom: 0, left: safeAreaLayoutGuide.leftAnchor, paddingLeft: 8, right: nil, paddingRight: 0, height: 48, width: 48)
        profileImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(timeLabel)
        timeLabel.layoutAnchor(top: topAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: safeAreaLayoutGuide.rightAnchor, paddingRight: 0, height: 30, width: 100)
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
