//
//  Message.swift
//  RealTimeChat
//
//  Created by Keith Cao on 17/07/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase

struct Message  {
    
    var fromID: String?
    var text: String?
    var timestamp: Date?
    var toID: String?
    let imageUrl: String?
    var imageHeight: CGFloat?
    var imageWidth: CGFloat?
    var videoUrl: String?
    
    init(dict: [String: Any]) {
        self.fromID = dict["fromID"] as? String
        self.text = dict["text"] as? String
        
        let secondsFrom1970 = dict["time"] as! Double
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
        self.toID = dict["toID"] as? String ?? ""
        self.imageUrl = dict["imageUrl"] as? String
        self.imageHeight = dict["imageHeight"] as? CGFloat
        self.imageWidth = dict["imageWidth"] as? CGFloat
        self.videoUrl = dict["videoUrl"] as? String
    }
    
    func chatPartnerID() -> String? {
        
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
        
    }
    
}
