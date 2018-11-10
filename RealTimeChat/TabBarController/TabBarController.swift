//
//  TabBarController.swift
//  RealTimeChat
//
//  Created by Keith Cao on 1/08/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase


class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var messageController: MessageController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("reach tabbar")
        
        self.delegate = self
        
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let naviController = UINavigationController(rootViewController: loginController)
                self.present(naviController, animated: true, completion: nil)
            }
            return
        }
        
        setUpViewController()
        
        self.selectedIndex = 0
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkRequestNumber()
    }
    
    
    func checkRequestNumber(){
        print("checkrequest number")
        let tabbarItem = tabBar.items![1]
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("requestNumber").child(uid)
        
        ref.observe(.value, with: { (snapshot) in
            
            
            guard let dict = snapshot.value as? [String: Any] else { return }
            
            guard let number = dict["number"] as? Int else { return }
            
            
            if number == 0 {
                tabbarItem.badgeValue = ""
                tabbarItem.badgeColor = UIColor.init(r: 248, g: 248, b: 248)
            } else {
                tabbarItem.badgeValue = "\(number)"
                tabbarItem.badgeColor = .red
            }
            
            
        }, withCancel: nil)
        
        
        
        
    }
    
    func setUpViewController() {
        
        
        
        let messageController = UINavigationController(rootViewController: MessageController())
        messageController.tabBarItem.image = #imageLiteral(resourceName: "chat")
        
        
        let profileController = UINavigationController(rootViewController: ProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        profileController.tabBarItem.image = #imageLiteral(resourceName: "user_profile_unselect")
        profileController.tabBarItem.selectedImage = #imageLiteral(resourceName: "user_profile_selected")
        viewControllers = [messageController,profileController]
        
        //set up the badgevalue which will appear on the top right corner of the tabbar badge
        
        guard let items = tabBar.items else { return }
        for item in items {
            item.title = ""
            item.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -6, right: 0)
        }
        
    }
    
    
    
    
}
