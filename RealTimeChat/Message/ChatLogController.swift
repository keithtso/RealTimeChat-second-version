//
//  ChatLogController.swift
//  RealTimeChat
//
//  Created by Keith Cao on 15/07/18.
//  Copyright © 2018 Keith Cao. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, CustomInputViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    func showImagePicker(picker: UIImagePickerController) {
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            handleVideoSelectedForUrl(videoUrl: videoUrl)
            
            
        } else {
            
            handleImageSelectedInfo(info: info)
            
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    private func handleImageSelectedInfo(info:[String : Any]) {
        
        var selecterImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selecterImage = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selecterImage = originalImage
        }
        
        if let image = selecterImage {
            upLoadImageToFirebase(image: image) { (imageUrl) in
                self.sendImageWithUrl(imageUrl: imageUrl, image: image)
            }
        }
        
        
    }
    
    
    private func handleVideoSelectedForUrl(videoUrl: URL) {
        
        let fileName = UUID().uuidString + ".mov"
        
        let ref = Storage.storage().reference().child("message_movie").child(fileName)
        
        let uploadTask =  ref.putFile(from: videoUrl, metadata: nil) { (metaData, err) in
            
            if err != nil {
                print("fail to upload video ", err as Any)
                return
            }
            
            ref.downloadURL(completion: { (url, err) in
                
                if err != nil   {
                    print("fail to download videoURl ", err as Any)
                    return
                }
                
                guard let thumbnailImage = self.thumbnailImageForVideoUrl(videoUrl: videoUrl) else {return}
                
                self.upLoadImageToFirebase(image: thumbnailImage, completion: { (imageUrl) in
                    guard let videoDownloadUrl = url?.absoluteString else {return}
                    
                    self.sendVideoWithUrl(videoUrl: videoDownloadUrl, firstImage: thumbnailImage, imageUrl: imageUrl)
                    print(videoDownloadUrl)
                })
                
                
                
            })
            
            
            
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            
            print(snapshot.progress?.completedUnitCount as Any)
            
        }
        
    }
    
    fileprivate func thumbnailImageForVideoUrl(videoUrl: URL) -> UIImage? {
        
        let asset = AVAsset(url: videoUrl)
        
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnailCGImage = try assetGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        
        return nil
        
    }
    
    fileprivate func sendVideoWithUrl(videoUrl: String, firstImage: UIImage, imageUrl: String) {
        
        let ref = Database.database().reference().child("messages").childByAutoId()
        
        guard let receiverID = receiver?.id else { return }
        guard let sendID = Auth.auth().currentUser?.uid else { return }
        let timestamp = NSDate().timeIntervalSince1970
        
        
        let values = ["videoUrl":videoUrl, "imageUrl": imageUrl, "imageHeight":firstImage.size.height ,"imageWidth": firstImage.size.width ,"toID": receiverID, "fromID":sendID, "time": timestamp] as [String : Any]
        ref.updateChildValues(values)
        
        ref.updateChildValues(values) { (error, refone) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            self.inputContainerView.clearInputTextField()
            
            
            let userMessageRef = Database.database().reference().child("user-messages").child(sendID).child(receiverID)
            
            let messageID = ref.key
            
            userMessageRef.updateChildValues([messageID: 1])
            
            let receiveIDRef = Database.database().reference().child("user-messages").child(receiverID).child(sendID)
            
            receiveIDRef.updateChildValues([messageID: 1])
        }
        
    }
    
    
    fileprivate func upLoadImageToFirebase(image: UIImage, completion: @escaping (_ imagaUrl: String) -> () ){
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        guard let uploadData = UIImageJPEGRepresentation(image, 0.2) else {return}
        
        ref.putData(uploadData, metadata: nil) { (metaData, err) in
            
            if err != nil {
                print("fail to upload message",err as Any)
                return
            }
            
            ref.downloadURL(completion: { (url, err) in
                
                if err != nil {
                    print("fail to download image url ", err as Any)
                    return
                }
                
                guard let downloadUrl = url?.absoluteString else { return }
                completion(downloadUrl)
                
                
            })
            
            print("uploaded")
        }
        
        
    }
    
    
    fileprivate func sendImageWithUrl(imageUrl: String, image: UIImage) {
        
        let ref = Database.database().reference().child("messages").childByAutoId()
        
        guard let receiverID = receiver?.id else { return }
        guard let sendID = Auth.auth().currentUser?.uid else { return }
        let timestamp = NSDate().timeIntervalSince1970
        
        let values = ["imageUrl": imageUrl, "imageHeight":image.size.height ,"imageWidth": image.size.width ,"toID": receiverID, "fromID":sendID, "time": timestamp] as [String : Any]
        
        ref.updateChildValues(values) { (error, refone) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            self.inputContainerView.clearInputTextField()
            
            
            let userMessageRef = Database.database().reference().child("user-messages").child(sendID).child(receiverID)
            
            let messageID = ref.key
            
            userMessageRef.updateChildValues([messageID: 1])
            
            let receiveIDRef = Database.database().reference().child("user-messages").child(receiverID).child(sendID)
            
            receiveIDRef.updateChildValues([messageID: 1])
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func hasSent(text: String) {
        print("send ", text)
        let ref = Database.database().reference().child("messages").childByAutoId()
        
        guard let receiverID = receiver?.id else { return }
        guard let sendID = Auth.auth().currentUser?.uid else { return }
        let timestamp = NSDate().timeIntervalSince1970
        let values = ["text": text, "toID": receiverID, "fromID":sendID, "time": timestamp] as [String : Any]
        
        ref.updateChildValues(values) { (error, refone) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            self.inputContainerView.clearInputTextField()
            
            
            let userMessageRef = Database.database().reference().child("user-messages").child(sendID).child(receiverID)
            
            let messageID = ref.key
            
            userMessageRef.updateChildValues([messageID: 1])
            
            let receiveIDRef = Database.database().reference().child("user-messages").child(receiverID).child(sendID)
            
            receiveIDRef.updateChildValues([messageID: 1])
        }
        
    }
    
    
    let cellID = "CellID"
    
    
    var receiver: User? {
        didSet{
            navigationItem.title = receiver?.name
            
            checkMessages()
        }
    }
    
    var messages = [Message]()
    var timer: Timer?
    
    func checkMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid , let toID = receiver?.id else { return }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toID)
        
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let mesageID = snapshot.key
            
            let messageRef = Database.database().reference().child("messages").child(mesageID)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dict = snapshot.value as? [String:Any] else {
                    return
                }
                
                let message = Message(dict: dict)
                
                
                
                self.messages.append(message)
                
                
                //set the timer and reduce the reload times
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1 , target: self, selector: #selector(self.handleMessageLoacate), userInfo: nil, repeats: false)
                
                
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }
    
    
    @objc func handleMessageLoacate() {
        print("reload chatlog")
        self.collectionView?.reloadData()
        DispatchQueue.main.async {
            
            if self.messages.count > 0 {
                let indextPath = IndexPath(item: self.messages.count - 1, section: 0)
                
                self.collectionView?.scrollToItem(at: indextPath, at: .bottom, animated: true)
                
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        collectionView?.alwaysBounceVertical = true
        
        
        //makes some padding on top of each cell
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        
        collectionView?.keyboardDismissMode = .interactive
        
        setUpKeyboardObserver()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleScreenLandscape), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func setUpKeyboardObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexpath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexpath, at: .bottom, animated: true)
        }
        
        
    }
    
    lazy var inputContainerView: CustomInputView = {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let containter = CustomInputView(frame: frame)
        containter.delegate = self
        
        return containter
        
    }()
    
    
    override var inputAccessoryView: UIView? {
        
        get{
            
            return inputContainerView
        }
        
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        
        cell.message = message
        
        cell.charlogController = self
        
        cell.textView.text = message.text
        
        setUpCell(cell: cell, message: message)
        
        
        if let text = message.text {
            
            cell.textView.isHidden = false
            
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 20
            
        } else if message.imageUrl != nil {
            
            //set up the image constant width
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    private func setUpCell(cell:ChatMessageCell, message: Message) {
        
        if let profileImageUrl = self.receiver?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrl(urlString: profileImageUrl)
        }
        
        
        
        if message.fromID == Auth.auth().currentUser?.uid {
            
            cell.bubbleView.backgroundColor = ChatMessageCell.textBubbleColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        } else {
            
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        if  let messageUrl = message.imageUrl {
            
            
            cell.messageImageView.loadImageUsingCacheWithUrl(urlString: messageUrl)
            cell.messageImageView.isHidden = false
            
            cell.bubbleView.backgroundColor = .clear
            
        } else {
            cell.messageImageView.isHidden = true
            
            
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimatedFrameForText(text: text).height + 20
        }else if message.imageUrl != nil {
            if let imageHeight = message.imageHeight, let imageWidth = message.imageWidth {
                
                // h1 / w1 = h2 / w2
                
                height = imageHeight / imageWidth * 200
                
            }
            
            
        }
        
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
        
        
    }
    
    fileprivate func estimatedFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
        
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    var height: CGFloat?
    
    var backView: UIView?
    
    func performZoomInForImage(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        self.inputContainerView.inputTextfield.resignFirstResponder()
        
        self.startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            self.backView = UIView()
            backView?.backgroundColor = .black
            backView?.alpha = 0
            
            self.blackBackgroundView = UIView()
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(backView!)
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            backView?.layoutAnchor(top: keyWindow.topAnchor, paddingTop: 0, bottom: keyWindow.bottomAnchor, paddingBottom: 0, left: keyWindow.leftAnchor, paddingLeft: 0, right: keyWindow.rightAnchor, paddingRight: 0, height: 0, width: 0)
            
            blackBackgroundView?.layoutAnchor(top: keyWindow.safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottom: keyWindow.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, left: keyWindow.safeAreaLayoutGuide.leftAnchor, paddingLeft: 0, right: keyWindow.safeAreaLayoutGuide.rightAnchor, paddingRight: 0, height: 0, width: 0)
            
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.backView?.alpha = 1
                self.inputContainerView.alpha = 0
                self.view.backgroundColor = .black
                
                // h2 / w2 = h1 / w2
                
                guard let startingFrameHeight = self.startingFrame?.height, let startingFrameWidth = self.startingFrame?.width else {return}
                
                
                
                if UIDevice.current.orientation.isLandscape{
                    
                    self.height = startingFrameHeight / startingFrameWidth * keyWindow.frame.height
                    
                } else {
                    
                    self.height = startingFrameHeight / startingFrameWidth * keyWindow.frame.width
                    
                }
                
                zoomingImageView.layoutAnchor(top: nil, paddingTop: 0, bottom: nil, paddingBottom: 0, left: self.blackBackgroundView?.leftAnchor, paddingLeft: 0, right: self.blackBackgroundView?.rightAnchor, paddingRight: 0, height: self.height!, width: 0)
                zoomingImageView.centerYAnchor.constraint(equalTo: (self.blackBackgroundView?.centerYAnchor)!).isActive = true
                
                
            }) { (complete: Bool) in
                
                
            }
            
        }
        
        
        
    }
    
    @objc func handleScreenLandscape() {
        
        self.inputAccessoryView?.isHidden = true
        
    }
    
    @objc func handleZoomOut(gesture: UITapGestureRecognizer) {
        
        if let zoomoutImageView = gesture.view {
            
            zoomoutImageView.layer.cornerRadius = 16
            zoomoutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomoutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.backView?.alpha = 0
                self.view.backgroundColor = .white
                self.inputContainerView.alpha = 1
                
                
            }) { (complete: Bool) in
                
                
                zoomoutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                self.inputAccessoryView?.isHidden = false
                
                
            }
            
        }
        
    }
    
    
}
