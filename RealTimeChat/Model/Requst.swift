//
//  Requst.swift
//  RealTimeChat
//
//  Created by Keith Cao on 13/08/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit

struct Requst {
    
    let fromId: String?
    let date: Date?
    var currentUserID: String?
    var requestID: String?
    
    
    init(Dictionary: [String:Any]) {
        self.fromId = Dictionary["from"] as? String
        
        
        let secondsFrom1970 = Dictionary["date"] as! Double
        self.date = Date(timeIntervalSince1970: secondsFrom1970)
        
    }
    
}
