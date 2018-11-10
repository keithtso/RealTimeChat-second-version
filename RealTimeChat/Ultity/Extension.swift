//
//  Extension.swift
//  RealTimeChat
//
//  Created by Keith Cao on 15/07/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase

let imageCache = NSCache<AnyObject, AnyObject>()


extension UINavigationItem {
    
    func setUpNavTitle(nameLabel: String) {
        let attributeText = NSAttributedString(string: nameLabel, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 22)])
        let titleLabel = UILabel()
        
        titleLabel.layer.shadowColor = UIColor.darkGray.cgColor
        titleLabel.layer.shadowRadius = 3.0
        titleLabel.layer.shadowOpacity = 1.0
        titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        titleLabel.layer.masksToBounds = false
        titleLabel.attributedText = attributeText
        self.titleView = titleLabel
    }
    
}


extension Database {
    
    static func updateRequestNumber(difference: Int, id: String) {
        
        let ref = Database.database().reference().child("requestNumber").child(id)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: Any] else { return }
            
            guard let number = dict["number"] as? Int else {
                let value = ["number": 0 + difference ]
                
                ref.updateChildValues(value)
                return
            }
            
            
            if !(number < 0) {
                let value = ["number": number + difference ]
                
                ref.updateChildValues(value)
                
            }
            
            
            
        }, withCancel: nil)
        
    }
    
}



extension String {
    
    func encodeKey() -> String {
        
        return self.replacingOccurrences(of: ".", with: "(U+002E)")
        
    }
    
}


extension UIViewController {
    
    static func setUpCollectionViewSafearea(view: UIView, subview:UIView) {
        let margin = view.safeAreaLayoutGuide
        subview.layoutAnchor(top: view.topAnchor, paddingTop: 0, bottom: margin.bottomAnchor, paddingBottom: 0, left: margin.leftAnchor, paddingLeft: 0, right: margin.rightAnchor, paddingRight: 0, height: 0, width: 0)
    }
    
}


extension UIImageView {
    
    func loadImageUsingCacheWithUrl(urlString: String){
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        if let url = URL(string: urlString) {
            
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                if let err = err {
                    print("fail to download profile image url ", err)
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if let downloadImage = UIImage(data: data!) {
                        imageCache.setObject(downloadImage, forKey: urlString as AnyObject)
                        self.image = downloadImage
                    }
                    
                    
                }
                
                }.resume()
            
        }
    }
    
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = minute * 60
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondAgo < minute {
            quotient = secondAgo
            unit = "second"
            
        }else if secondAgo < hour {
            quotient = secondAgo / minute
            unit = "min"
        } else if secondAgo < day {
            quotient = secondAgo / hour
            unit = "hour"
        } else if secondAgo < week {
            quotient = secondAgo / day
            unit = "day"
        }else if secondAgo < month {
            quotient = secondAgo / week
            unit = "week"
        } else {
            quotient = secondAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
    }
    
}

