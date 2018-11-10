//
//  LoginController+handler.swift
//  RealTimeChat
//
//  Created by Keith Cao on 14/07/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func addProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profileImageView.image = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profileImageView.image = originalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    @objc func handleLoginSegment() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change height of inputcontainerview
        inputContainerHeightConstraint?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        profileImageView.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? true : false
        //change height of nametextfield
        nameTextFieldHeight?.isActive = false
        nameTextFieldHeight = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeight?.isActive = true
        
        
        //change height of emailtextfield
        emailTextFieldHeight?.isActive = false
        emailTextFieldHeight = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeight?.isActive = true
        
        //change height of passwordtextfield
        passwordTextFieldHeight?.isActive = false
        passwordTextFieldHeight = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeight?.isActive = true
        
    }
    
    @objc func handleKeyboardDismiss() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }else {
            handleRegister()
        }
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? TabBarController else { return }
            mainTabBarController.setUpViewController()
            mainTabBarController.selectedIndex = 0
            self.tabbarController?.messageController?.fetchUserWithNavBarTitile()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleRegister() {
        
        guard let email = emailTextField.text , let password = passwordTextField.text, let nameText = nameTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("Form is not valid")
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let fileName = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profileImage").child(fileName)
            
            guard let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.4) else { return }
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                
                if let err = err {
                    print("fail to upload profile image", err)
                    return
                }
                
                
                storageRef.downloadURL(completion: { (url, error) in
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    guard let downloadUrl = url?.absoluteString else { return }
                    
                    let value = ["name": nameText, "email": email, "profileImageUrl": downloadUrl]
                    self.registerUserWithUid(uid: uid, values: value)
                    
                })
                
                
                
            })
            
            
        }
    }
    
    private func registerUserWithUid(uid: String, values: [String: Any] ) {
        let ref = Database.database().reference()
        let childRef = ref.child("users").child(uid)   // create a user with an ID
        
        childRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err as Any)
                return
            }
            print("user saved successfully")
            let user = User(dictionary: values)
            print( user )
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? TabBarController else { return }
            mainTabBarController.setUpViewController()
            self.tabbarController = mainTabBarController
            
            self.tabbarController?.messageController?.setUpNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
        
        //create a email address list
        guard let emailID = values["email"] as? String else { return }
        let key = emailID.encodeKey()
        ref.child("emailID").child(key).updateChildValues(["uid": uid ])
        ref.child("requestNumber").child(uid).updateChildValues(["number": 0])
    }
    
    
    
}
