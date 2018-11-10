//
//  NewMessageCell.swift
//  RealTimeChat
//
//  Created by Keith Cao on 13/07/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit

class  NewMessageCell: UITableViewCell {
    
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        
        
        addSubview(profileImage)
        
        profileImage.layoutAnchor(top: nil  , paddingTop: 0, bottom: nil, paddingBottom: 0, left: safeAreaLayoutGuide.leftAnchor, paddingLeft: 8, right: nil, paddingRight: 0, height: 48, width: 48)
        profileImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
