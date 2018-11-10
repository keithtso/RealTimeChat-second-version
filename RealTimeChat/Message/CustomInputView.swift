//
//  CustomInputView.swift
//  RealTimeChat
//
//  Created by Keith Cao on 26/07/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit


protocol CustomInputViewDelegate {
    func hasSent(text: String)
    func showImagePicker(picker: UIImagePickerController)
}

class CustomInputView: UIView, UITextFieldDelegate {
    
    var delegate: CustomInputViewDelegate?
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSend() {
        guard let text = inputTextfield.text else { return }
        delegate?.hasSent(text: text)
    }
    
    lazy var inputTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Enter messages"
        textfield.font = UIFont.systemFont(ofSize: 14)
        textfield.delegate = self
        return textfield
    }()
    
    func clearInputTextField() {
        inputTextfield.text = nil
    }
    
    let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
        
    }()
    
    let seperatorLineBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
        
    }()
    
    lazy var uploadImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "plus_unselected")
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickImage)))
        return iv
    }()
    
    @objc func handlePickImage() {
        
        print("picking image")
        
        let imagePicker = UIImagePickerController()
        delegate?.showImagePicker(picker: imagePicker)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        
        backgroundColor = .white
        
        let container = UIView()
        addSubview(container)
        
        container.layoutAnchor(top: safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottom: safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, left: safeAreaLayoutGuide.leftAnchor, paddingLeft: 0, right: safeAreaLayoutGuide.rightAnchor, paddingRight: 0, height: 0, width: 0)
        
        container.addSubview(sendButton)
        container.addSubview(inputTextfield)
        container.addSubview(seperatorLine)
        container.addSubview(seperatorLineBottom)
        container.addSubview(uploadImageView)
        
        uploadImageView.layoutAnchor(top: nil, paddingTop: 0, bottom: nil, paddingBottom: 0, left: container.leftAnchor, paddingLeft: 0, right: nil, paddingRight: 0, height: 44, width: 44)
        uploadImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        sendButton.layoutAnchor(top: container.topAnchor, paddingTop: 8, bottom: container.bottomAnchor, paddingBottom: 8, left: nil, paddingLeft: 0, right: container.rightAnchor, paddingRight: 8, height: 0, width: 50)
        
        inputTextfield.layoutAnchor(top: container.topAnchor, paddingTop: 8, bottom: container.bottomAnchor, paddingBottom: 8, left: uploadImageView.rightAnchor, paddingLeft: 8, right: sendButton.leftAnchor, paddingRight: 8, height: 0, width: 0)
        
        seperatorLine.layoutAnchor(top: container.topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: container.leftAnchor, paddingLeft: 0, right: container.rightAnchor, paddingRight: 0, height: 0.5, width: 0)
        
        seperatorLineBottom.layoutAnchor(top: container.bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: container.leftAnchor, paddingLeft: 0, right: container.rightAnchor, paddingRight: 0, height: 0.5, width: 0)
        
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
