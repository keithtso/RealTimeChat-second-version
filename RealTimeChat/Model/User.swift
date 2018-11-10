//
//  User.swift
//  RealTimeChat
//
//  Created by Keith Cao on 12/06/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit

struct User {
    var name: String?
    var email: String?
    var profileImageUrl: String?
    var id: String?
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
    
}
